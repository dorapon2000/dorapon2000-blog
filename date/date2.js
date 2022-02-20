import { format, formatISO, getDay, add, sub } from 'date-fns'

// 現在時刻/今日のDate型
const now = new Date()
const today = (() => {
  const now = new Date()
  return new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0)
})()

// 文字列 → Date型
const dtNopadding = new Date('2022/2/10 1:00:00')
const dtpadding = new Date('2022-02-10 01:00')
const dtISO = new Date('2022-02-10T01:00:00')

// Date型 → 文字列
console.log(format(now, 'y年M月d日 H時m分s秒')) // 2022年2月20日 19時43分43秒
console.log(format(now, 'yyyy年MM月dd日 HH時mm分ss秒')) // 2022年02月20日 19時43分43秒
console.log(formatISO(now)) // 2022-02-20T19:43:43+09:00

// 曜日を日本語で取得
console.log('日月火水木金土'.charAt(getDay(now))) // 日

// 足し算と引き算
const future = add(now, { days: 10, hours: 10, minutes: 10, seconds: 10 })
console.log(future) // 2022-03-02T20:53:53.284Z

const past = sub(now, { days: 10, hours: 10, minutes: 10, seconds: 10 })
console.log(past) // 2022-02-10T00:33:33.284Z

// 比較
console.log(`${now < future}`) // true

// タイムゾーン
const nowJst = new Date().toLocaleString({ timeZone: 'Asia/Tokyo' })
