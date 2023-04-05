
#############################################################
#   This code was written by vanbka9 with <3 for QRA-Team   #
#                        04.04.2023                         #
#############################################################

import pandas as pd

# Переменные для имён файлов 
DMRIds_file = 'DMRIds.dat'
output_file = 'Takt_Contact.xls'

# Создание объекта ExcelWriter и запись данных
writer = pd.ExcelWriter(output_file, engine='openpyxl')

# Обработка файла DMRIds_file, добавление необходимого форматирования
df = pd.read_csv(DMRIds_file, header=None, sep="\t", engine="python", encoding='utf-8')
df["No."] = range(1, len(df) + 1)
df["Call Type"] = "Private Call"
df = df.rename( columns={0: "Call ID", 1: "Call Alias"}) \
       .reindex(columns=['No.', 'Call Alias', 'Call Type', 'Call ID'])

# krot4u, убери это в месте с блоком "# Обрезаем" если оно не пригодится =)
# Функция для обрезания ID до 7 знаков
def f_trunk(str):
    return str[:7] if len(str) > 7 else str

# Обрезаем
df['Call Alias'] = df['Call Alias'].apply(f_trunk)

# Проверка данных на уникальность имён
# Если есть повторы - добавляем в конец инкремент
# учитывая что длинна имени должна быть не больше 7 знаков
counts = df["Call Alias"].value_counts()
for index, value in counts.items():
    if value > 1:
        inc = 1
        for i, row in df.iterrows():
            if row["Call Alias"] == index:
                index = index[:6]
                df.at[i, "Call Alias"] = f"{index}{inc}"
                inc += 1

# Скелет таблицы
table = {
    'DMR Services_Contact':         df
    }

# Запись данных из списка table
for name, data in table.items():
    if name == 'DMR Services_Contact':
        df.to_excel(writer, sheet_name=name, index=False)
        continue
    df1 = pd.DataFrame(data[1:], columns=data[0])
    df1.to_excel(writer, sheet_name=name, index=False)

# Сохранение изменений в файл
writer._save()