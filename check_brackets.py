path = r'admin/lib/screens/reports/reports_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    s = f.read()
pairs = {'(':')','[':']','{':'}'}
stack=[]
errors=[]
for idx,ch in enumerate(s, start=1):
    if ch in pairs:
        stack.append((ch, idx))
    elif ch in pairs.values():
        if not stack:
            errors.append((idx, 'unmatched closing', ch))
        else:
            last, pos = stack.pop()
            if pairs[last] != ch:
                errors.append((idx, f'mismatch {last} at {pos} closed by {ch}', ch))

if stack:
    errors.extend([(pos, 'unclosed', last) for (last,pos) in stack[::-1]])

for pos, typ, ch in errors:
    line = s.count('\n', 0, pos) + 1
    col = pos - s.rfind('\n', 0, pos)
    print(pos, typ, ch, '-> line', line, 'col', col)
    start = max(0, pos-60)
    end = min(len(s), pos+60)
    print('\nContext:\n')
    print(s[start:end])
    print('\n---')
