import {after, before, beforeEach, describe, test} from 'node:test';
import {readFileSync} from 'node:fs';
import {assertFails, assertSucceeds, initializeTestEnvironment} from '@firebase/rules-unit-testing';
import {equalTo, get, orderByChild, query, ref, remove, runTransaction, serverTimestamp, set, update} from 'firebase/database';

let env;
const drug = (id, extra = {}) => ({id, name: id, ingredient: 'x', category: 'Pain & fever', price: 20000, prescription: false, stock: 5, ...extra});
const order = (id, uid, extra = {}) => ({
  id, uid, name: 'An', phone: '0900000000', address: '1 Le Loi', status: 'pending', stockDeducted: false,
  createdAt: serverTimestamp(), items: {para: {name: 'para', price: 20000, qty: 2}}, ...extra,
});
const db = uid => (uid ? env.authenticatedContext(uid) : env.unauthenticatedContext()).database();

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-doctorapp',
    database: {host: '127.0.0.1', port: 9000, rules: readFileSync(new URL('../../database.rules.json', import.meta.url), 'utf8')},
  });
});
after(() => env.cleanup());
beforeEach(async () => {
  await env.clearDatabase();
  await env.withSecurityRulesDisabled(async ctx => {
    const admin = ctx.database();
    await set(ref(admin, 'Pharmacists/pharma'), {email: 'p@x.vn'});
    await set(ref(admin, 'Drugs/para'), drug('para'));
    await set(ref(admin, 'Drugs/amox'), drug('amox', {prescription: true}));
    await set(ref(admin, 'Orders/o1'), {...order('o1', 'alice'), createdAt: 1});
  });
});

describe('Pharmacists', () => {
  test('nobody can grant themselves the role', () => assertFails(set(ref(db('alice'), 'Pharmacists/alice'), {email: 'a'})));
  test('a pharmacist can read their own marker only', async () => {
    await assertSucceeds(get(ref(db('pharma'), 'Pharmacists/pharma')));
    await assertFails(get(ref(db('alice'), 'Pharmacists/pharma')));
  });
});

describe('Doctors and patients', () => {
  const profile = (uid, extra = {}) => ({uid, firstName: uid, ...extra});
  const request = (id, sender, receiver, extra = {}) =>
    ({id, sender, receiver, date: '01/02/2026', time: '9:00 AM', description: 'x', status: 'pending', ...extra});
  beforeEach(() => env.withSecurityRulesDisabled(async ctx => {
    await set(ref(ctx.database(), 'Doctors/drv'), profile('drv', {verified: true}));
    await set(ref(ctx.database(), 'Doctors/drnew'), profile('drnew'));
    await set(ref(ctx.database(), 'Patients/alice'), profile('alice'));
  }));
  test('doctors cannot verify themselves or drop verification by editing', async () => {
    await assertFails(set(ref(db('drnew'), 'Doctors/drnew'), profile('drnew', {verified: true})));
    await assertFails(set(ref(db('drv'), 'Doctors/drv'), profile('drv')));
    await assertSucceeds(update(ref(db('drv'), 'Doctors/drv'), {firstName: 'Lan'}));
  });
  test('only admins verify or un-verify doctors, and nothing else', async () => {
    await env.withSecurityRulesDisabled(ctx => set(ref(ctx.database(), 'Admins/boss'), {email: 'b@x.vn'}));
    await assertFails(set(ref(db('pharma'), 'Doctors/drnew/verified'), true));
    await assertFails(set(ref(db('drnew'), 'Doctors/drnew/verified'), true));
    await assertFails(set(ref(db('boss'), 'Doctors/drnew/verified'), 'yes'));
    await assertFails(set(ref(db('boss'), 'Doctors/ghost/verified'), true));
    await assertFails(set(ref(db('boss'), 'Doctors/drnew/firstName'), 'X'));
    await assertSucceeds(set(ref(db('boss'), 'Doctors/drnew/verified'), true));
    await assertSucceeds(remove(ref(db('boss'), 'Doctors/drv/verified')));
    await assertFails(set(ref(db('boss'), 'Admins/boss2'), {email: 'x'}));
    await assertSucceeds(get(ref(db('boss'), 'Admins/boss')));
    await assertFails(get(ref(db('alice'), 'Admins/boss')));
  });
  test('only the patient and verified doctors read a patient profile', async () => {
    await assertSucceeds(get(ref(db('alice'), 'Patients/alice')));
    await assertSucceeds(get(ref(db('drv'), 'Patients/alice')));
    await assertFails(get(ref(db('drnew'), 'Patients/alice')));
    await assertFails(get(ref(db('bob'), 'Patients/alice')));
    await assertFails(get(ref(db('drv'), 'Patients')));
  });
  test('appointments go to verified doctors with a known status', async () => {
    await assertFails(set(ref(db('alice'), 'Requests/r1'), request('r1', 'alice', 'drnew')));
    await assertSucceeds(set(ref(db('alice'), 'Requests/r1'), request('r1', 'alice', 'drv')));
    await assertFails(update(ref(db('drv'), 'Requests/r1'), {status: 'Paid'}));
    await assertSucceeds(update(ref(db('drv'), 'Requests/r1'), {status: 'Accepted'}));
  });
});

describe('Chat', () => {
  const msg = (sender, receiver) => ({message: 'hi', sender, receiver, timestamp: '2026-01-01T00:00:00'});
  // Same multi-path write as ChatScreen._send.
  const send = (sender, receiver, chat, id = 'm1') => update(ref(db(sender)), {
    [`Chat/${chat}/${id}`]: msg(sender, receiver),
    [`ChatList/${sender}/${receiver}`]: {id: receiver},
    [`ChatList/${receiver}/${sender}`]: {id: sender},
  });
  beforeEach(() => env.withSecurityRulesDisabled(async ctx => {
    const admin = ctx.database();
    await set(ref(admin, 'Doctors/drbob'), {uid: 'drbob', verified: true});
    await set(ref(admin, 'Doctors/drnew'), {uid: 'drnew'});
    await set(ref(admin, 'Patients/alice'), {uid: 'alice'});
    await set(ref(admin, 'Patients/eve'), {uid: 'eve'});
  }));
  test('only the two participants read a conversation and chat list', async () => {
    await assertSucceeds(send('alice', 'drbob', 'alice_drbob'));
    await assertSucceeds(get(ref(db('alice'), 'Chat/alice_drbob')));
    await assertSucceeds(get(ref(db('drbob'), 'Chat/alice_drbob')));
    await assertFails(get(ref(db('eve'), 'Chat/alice_drbob')));
    await assertFails(get(ref(db('eve'), 'Chat')));
    await assertFails(get(ref(db('ali'), 'Chat/alice_drbob')));
    await assertSucceeds(get(ref(db('alice'), 'ChatList/alice')));
    await assertFails(get(ref(db('eve'), 'ChatList/alice')));
    await assertFails(get(ref(db('eve'), 'ChatList')));
  });
  test('messages cannot be forged, misfiled or edited', async () => {
    await assertFails(set(ref(db('eve'), 'Chat/alice_drbob/m2'), msg('alice', 'drbob')));
    await assertFails(set(ref(db('eve'), 'Chat/alice_drbob/m2'), msg('eve', 'drbob')));
    await assertSucceeds(set(ref(db('drbob'), 'Chat/alice_drbob/m2'), msg('drbob', 'alice')));
    await assertFails(set(ref(db('drbob'), 'Chat/alice_drbob/m2'), msg('drbob', 'alice')));
  });
  test('only patients and verified doctors message each other', async () => {
    await assertFails(send('alice', 'eve', 'alice_eve'));
    await assertFails(send('alice', 'drnew', 'alice_drnew'));
    await assertFails(send('drnew', 'alice', 'alice_drnew'));
    await assertSucceeds(send('drbob', 'eve', 'drbob_eve'));
  });
  test('chat list entries need a real conversation', async () => {
    await assertFails(set(ref(db('eve'), 'ChatList/drbob/eve'), {id: 'eve'}));
    await assertFails(set(ref(db('eve'), 'ChatList/eve/drbob'), {id: 'drbob'}));
    await send('eve', 'drbob', 'drbob_eve');
    await assertSucceeds(set(ref(db('eve'), 'ChatList/eve/drbob'), {id: 'drbob'}));
  });
});

describe('Drugs', () => {
  test('signed-in users read the catalog, guests do not', async () => {
    await assertSucceeds(get(ref(db('alice'), 'Drugs')));
    await assertFails(get(ref(db(), 'Drugs')));
  });
  test('only pharmacists write drugs', async () => {
    await assertFails(set(ref(db('alice'), 'Drugs/para/stock'), 99));
    await assertSucceeds(set(ref(db('pharma'), 'Drugs/vit'), drug('vit')));
  });
  test('stock stays a non-negative integer', async () => {
    await assertFails(set(ref(db('pharma'), 'Drugs/para/stock'), -1));
    await assertFails(set(ref(db('pharma'), 'Drugs/para/stock'), 1.5));
    await assertSucceeds(runTransaction(ref(db('pharma'), 'Drugs/para/stock'), s => s - 2));
  });
});

describe('Carts', () => {
  test('owner manages own cart with OTC drugs only', async () => {
    await assertSucceeds(set(ref(db('alice'), 'Carts/alice/para'), 2));
    await assertFails(set(ref(db('alice'), 'Carts/alice/amox'), 1));
    await assertFails(set(ref(db('alice'), 'Carts/alice/para'), 0));
    await assertFails(set(ref(db('bob'), 'Carts/alice/para'), 1));
    await assertFails(get(ref(db('bob'), 'Carts/alice')));
  });
});

describe('Orders', () => {
  test('patient places an order and clears the cart atomically', async () => {
    await set(ref(db('alice'), 'Carts/alice/para'), 2);
    await assertSucceeds(update(ref(db('alice')), {'Orders/o2': order('o2', 'alice'), 'Carts/alice': null}));
  });
  test('orders cannot be forged', async () => {
    await assertFails(set(ref(db('alice'), 'Orders/o3'), order('o3', 'bob')));
    await assertFails(set(ref(db('alice'), 'Orders/o3'), order('o3', 'alice', {status: 'shipping'})));
    await assertFails(set(ref(db('alice'), 'Orders/o3'), order('o3', 'alice', {items: {para: {name: 'para', price: 1, qty: 1}}})));
    await assertFails(set(ref(db('alice'), 'Orders/o3'), order('o3', 'alice', {items: {amox: {name: 'amox', price: 20000, qty: 1}}})));
    await assertFails(set(ref(db('alice'), 'Orders/o1'), order('o1', 'alice')));
  });
  test('patients query only their own orders; pharmacists read all', async () => {
    await assertSucceeds(get(query(ref(db('alice'), 'Orders'), orderByChild('uid'), equalTo('alice'))));
    await assertFails(get(query(ref(db('bob'), 'Orders'), orderByChild('uid'), equalTo('alice'))));
    await assertFails(get(ref(db('alice'), 'Orders')));
    await assertSucceeds(get(ref(db('pharma'), 'Orders')));
  });
  test('patient may only cancel a pending order', async () => {
    await assertFails(set(ref(db('bob'), 'Orders/o1/status'), 'cancelled'));
    await assertFails(set(ref(db('alice'), 'Orders/o1/status'), 'delivered'));
    await assertFails(set(ref(db('alice'), 'Orders/o1/stockDeducted'), true));
    await assertSucceeds(set(ref(db('alice'), 'Orders/o1/status'), 'cancelled'));
    await assertFails(set(ref(db('alice'), 'Orders/o1/status'), 'pending'));
  });
  test('pharmacist moves status and stock flag but cannot delete or edit items', async () => {
    await assertSucceeds(update(ref(db('pharma'), 'Orders/o1'), {status: 'shipping', stockDeducted: true}));
    await assertFails(set(ref(db('pharma'), 'Orders/o1/status'), 'lost'));
    await assertFails(remove(ref(db('pharma'), 'Orders/o1/status')));
    await assertFails(set(ref(db('pharma'), 'Orders/o1/items/para/qty'), 9));
    await assertFails(remove(ref(db('pharma'), 'Orders/o1')));
  });
});
