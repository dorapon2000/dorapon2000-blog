const params = new URLSearchParams(location.search);
const a = document.createElement('a');
a.href = params.get('to');
a.textContent = a.href;
document.body.append(a);
setTimeout(() => a.click(), Number(params.get('wait') ?? 0) * 1000);
