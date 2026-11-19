// compare.js
/* eslint-disable no-sparse-arrays -- 穴のある配列の挙動を確かめるため */
const _ = require('lodash')

const run = (fn) => {
  try {
    return JSON.stringify(fn())
  } catch (e) {
    return `${e.constructor.name}: ${e.message}`
  }
}
const row = (label, lodashFn, stdFn) => {
  const l = run(lodashFn)
  const s = run(stdFn)
  console.log(`${l === s ? '✓' : '✗'} ${label} | ${l} | ${s}`)
}

const isOdd = (x) => x % 2 === 1
const users = [
  { name: 'a', active: true },
  { name: 'b', active: false }
]

console.log('## filter')
row(
  '[1, 2, 3]',
  () => _.filter([1, 2, 3], isOdd),
  () => [1, 2, 3].filter(isOdd)
)
row(
  '[]',
  () => _.filter([], isOdd),
  () => [].filter(isOdd)
)
row(
  'undefined',
  () => _.filter(undefined, isOdd),
  () => undefined.filter(isOdd)
)
row(
  'null',
  () => _.filter(null, isOdd),
  () => null.filter(isOdd)
)
row(
  '{ a: 1, b: 2, c: 3 }',
  () => _.filter({ a: 1, b: 2, c: 3 }, isOdd),
  () => ({ a: 1, b: 2, c: 3 }.filter(isOdd))
)
row(
  "'123'",
  () => _.filter('123', isOdd),
  () => '123'.filter(isOdd)
)
row(
  '42',
  () => _.filter(42, isOdd),
  () => (42).filter(isOdd)
)
row(
  '[1, , 3]',
  () => _.filter([1, , 3], () => true),
  () => [1, , 3].filter(() => true)
)
row(
  '述語に { active: true }',
  () => _.filter(users, { active: true }),
  () => users.filter({ active: true })
)
row(
  "述語に 'active'",
  () => _.filter(users, 'active'),
  () => users.filter('active')
)
row(
  '述語なし',
  () => _.filter([0, 1, '', 'a']),
  () => [0, 1, '', 'a'].filter()
)

console.log('## keys')
const keysRow = (label, value) =>
  row(
    label,
    () => _.keys(value),
    () => Object.keys(value)
  )
keysRow('{ a: 1, b: 2 }', { a: 1, b: 2 })
keysRow('{}', {})
keysRow('undefined', undefined)
keysRow('null', null)
keysRow("'hi'", 'hi')
keysRow('42', 42)
keysRow('[1, , 3]', [1, , 3])
keysRow('{ [Symbol()]: 1, a: 1 }', { [Symbol()]: 1, a: 1 })
keysRow(
  '継承したプロパティ',
  Object.assign(Object.create({ inherited: 1 }), { own: 1 })
)
