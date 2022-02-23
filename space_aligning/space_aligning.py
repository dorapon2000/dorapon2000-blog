def print_align_left(label, value):
    """ラベルを左寄せ"""
    print(f'{label:<20}: {value}')


def print_align_right(label, value):
    """ラベルを右寄せ"""
    print(f'{label:>20}: {value}')


print_align_left('Country', 'Japan')
print_align_left('Anthem', 'Kimigayo')
print_align_left('Capital', 'Tokyo')
print_align_left('National language', 'Japanese')
print_align_left('Area', '377,975 km2')
print_align_left('Population', '126,226,568')

print('\n' + '*' * 40 + '\n')

print_align_right('Country', 'Japan')
print_align_right('Anthem', 'Kimigayo')
print_align_right('Capital', 'Tokyo')
print_align_right('National language', 'Japanese')
print_align_right('Area', '377,975 km2')
print_align_right('Population', '126,226,568')
