// report.js: 読み込めたリソースと CSP 違反を、ページの末尾に書き出す
window.R = {};
const violations = [];
document.addEventListener('securitypolicyviolation', (e) => {
  violations.push(`${e.effectiveDirective} が ${e.blockedURI} をブロック`);
});
window.addEventListener('load', () => {
  const lines = [];
  for (const img of document.querySelectorAll('img')) {
    const w = img.naturalWidth;
    const from = { 10: 'https', 20: 'http（攻撃者）', 30: 'data:' }[w];
    lines.push(`${img.id}: ${w ? `表示（${from}）` : '失敗'}`);
  }
  for (const s of document.querySelectorAll('script[id]')) {
    lines.push(`${s.id}: ${R[s.id] ?? '実行されず'}`);
  }
  lines.push('--- CSP 違反 ---', ...violations);
  const pre = document.createElement('pre');
  pre.id = 'result';
  pre.textContent = lines.join('\n');
  document.body.append(pre);
});
