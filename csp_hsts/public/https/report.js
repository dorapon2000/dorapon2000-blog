// report.js: 読み込めたリソースと CSP 違反を、ページの末尾に書き出し、nginx の /report にも送る
window.R = {};
const violations = [];
document.addEventListener('securitypolicyviolation', (e) => {
  violations.push(`${e.effectiveDirective}:${e.blockedURI}`);
});
window.addEventListener('load', () => {
  const result = [];
  for (const img of document.querySelectorAll('img')) {
    result.push([img.id, { 10: 'https', 20: 'http', 30: 'data' }[img.naturalWidth] ?? 'failed']);
  }
  for (const s of document.querySelectorAll('script[id]')) {
    result.push([s.id, R[s.id] ?? 'not-executed']);
  }
  for (const v of violations) result.push(['csp-violation', v]);
  const pre = document.createElement('pre');
  pre.textContent = result.map(([k, v]) => `${k}: ${v}`).join('\n');
  document.body.append(pre);
  fetch(`/report?${new URLSearchParams(result)}`);
});
