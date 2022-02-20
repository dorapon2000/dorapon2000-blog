function copyDate(future) {
  return new Date(future.getTime())
}

// 現在時刻/今日のDate
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
const y = now.getFullYear()
const M = now.getMonth()
const d = now.getDay()
const H = now.getHours()
const m = now.getMinutes()
const s = now.getSeconds()
console.log(`${y}年${M}月${d}日 ${H}時${m}分${s}秒`) // 2022年1月0日 19時42分24秒

const yyyy = now.getFullYear().toString().padStart(4, '0')
const MM = now.getMonth().toString().padStart(2, '0')
const dd = now.getDay().toString().padStart(2, '0')
const HH = now.getHours().toString().padStart(2, '0')
const mm = now.getMinutes().toString().padStart(2, '0')
const ss = now.getSeconds().toString().padStart(2, '0')
console.log(`${yyyy}-${MM}-${dd}T${HH}:${mm}:${ss}`) // 2022-01-00T19:42:24

// 曜日を日本語で取得
console.log('日月火水木金土'.charAt(now.getDay())) // 日

// 足し算と引き算
const future = copyDate(now)
future.setDate(future.getDate() + 10)
future.setHours(future.getHours() + 10)
future.setMinutes(future.getMinutes() + 10)
future.setSeconds(future.getSeconds() + 10)
console.log(future) // Thu Mar 03 2022 05:52:34 GMT+0900 (日本標準時)

const past = copyDate(now)
past.setDate(past.getDate() - 10)
past.setHours(past.getHours() - 10)
past.setMinutes(past.getMinutes() - 10)
past.setSeconds(past.getSeconds() - 10)
console.log(past) //  Thu Feb 10 2022 09:32:14 GMT+0900 (日本標準時)

// 比較
console.log(`${now < future}`) // true

// タイムゾーン
const nowJst = new Date().toLocaleString({ timeZone: 'Asia/Tokyo' })
