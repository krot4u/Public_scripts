
# дать права на запуск (на всякий, точно не знаю)
# запускать так: python /path/to/file/test.py

# если петухон жалуется на отсутствие подключаемых модулей
# устанавливаем ручками их при помощи pip
# pip install pandas

# если нет pip - устанавливаем его:
# Download the script, from https://bootstrap.pypa.io/get-pip.py
# Open a terminal/command prompt, cd to the folder containing the get-pip.py file and run:
# python get-pip.py
# More details about this script can be found in pypa/get-pip’s README.

import os
import csv
import xlwt
import shutil
import pandas as pd

# имя файла c ID вида:
# 2120212  V6TURBO
# 2150215  ARCTIC
# 2500610  ONTONIO
ids_file    = 'DMRIds.dat'
# имя рабочей папки
folder_path = 'tmp'
# имя входного файла
import_file = 'input.xls'
# имя выходного файла
output_file = 'output.xls'
# имя файла в который пишем контакты
target_csv  = 'DMR Services_Contact.csv'

# если есть папка - удаляем её
if os.path.exists(folder_path):
    shutil.rmtree(folder_path)
# создаем пустую папку
os.makedirs(folder_path)

# 
# обращаю внимание, что Customer Programmer Software for Hytera
# https://i.imgur.com/Y0TutTh.png (скриншот окна About) 
# выплевывает, соответственно и принимает список контактов только в формате Excel 97-2003
# 
# чтение файла
xls = pd.ExcelFile(import_file)

# запомним названия листов из XLS
sheet_names = xls.sheet_names

# сохранение каждого листа в файл CSV
for sheet_name in sheet_names:
    df = pd.read_excel(xls, sheet_name)
    # с сохранением имени листа из XLS
    df.to_csv(f'{folder_path}/{sheet_name}.csv', index=False)

# код для замены данных в "DMR Services_Contact.csv"
# файл хранится в таком представлении:

# No.,  Call Alias, Call Type,      Call ID
# 1,    1-ОК,       Group Call,     11
# 2,    203 ALEX,   Private Call,   5973203
# 3,    215,        Private Call,   5973215

# данные для добавления берутся в виде:
# 2120212  V6TURBO
# 2150215  ARCTIC
# 2500610  ONTONIO

# чтение исходного файла, оставляем только заголовки
with open(f'{folder_path}/{target_csv}', 'r', encoding='utf-8') as f1:
    reader = csv.reader(f1)
    head = next(reader)

# чтение файла с айдишками, добавляем имена столбцам
df = pd.read_csv(ids_file, header=None, sep="  ", engine="python", encoding='utf-8')
df.columns = ["Call ID", "Call Alias"]

# добавление столбца "No." с порядковыми номерами
df["No."] = range(1, len(df) + 1)

# добавление столбца "Call Type" со значением "Private Call"
df["Call Type"] = "Private Call"

# сотрируем столбцы а соответствии с исходным файлом
df = df.reindex(columns=head)

# функция для обрезки всех Call Alias до 7 знаков
def process_call_alias(alias):
    print(alias)
    if len(alias) > 7:
        alias = alias[:7]
    return alias

# обрезаем 
df['Call Alias'] = df['Call Alias'].apply(process_call_alias)

# ищем повторы в столбце, если есть - обрезаем до 6 знаков
# и добавляем инкремент к иходному
alias_counts = df["Call Alias"].value_counts()
for index, value in alias_counts.items():
    if value > 1:
        increment = 1
        for i, row in df.iterrows():
            if row["Call Alias"] == index:
                index = index[:6]
                df.at[i, "Call Alias"] = f"{index}{increment}"
                increment += 1

# запись результата в файл
df.to_csv(f'{folder_path}/{target_csv}', index=False, encoding='utf-8')

# словарь для хранения объектов
data = {}

# чтение из CSV и сохранение в data
for file in sheet_names:
    data[file] = pd.read_csv(folder_path + '/' + file + ".csv") # na_values=['None']

# создание файла Excel 2003 
workbook = xlwt.Workbook(encoding='utf-8')

# цикл по именам CSV файлов
for csv_file in sheet_names:
    # открытие CSV файла
    with open(f'{folder_path}/{csv_file}.csv', 'r', encoding='utf-8') as f:
        # чтение CSV файла и запись данных в список rows
        reader = csv.reader(f)
        rows = [row for row in reader]
        # создание нового листа с именем CSV файла
        sheet = workbook.add_sheet(csv_file.split('.')[0])
        # запись данных из списка rows в лист
        for i, row in enumerate(rows):
            for j, cell in enumerate(row):
                # дикий костыль...
                # для добавления строки "None" напротив "Dial Rules"
                # т.к. при преобразовании в CSV значение "None" принимается за пустоту
                # программа должна обязательно прочитать строку "None", иначе она не принимает файл
                if sheet.name == 'Basic Information' and i == 3 and j == 1:
                    sheet.write(3, 1, "None")
                    break
                sheet.write(i, j, cell)
        
# сохранение Excel 2003 файла
workbook.save(output_file)

# удаление временной папки
shutil.rmtree(folder_path)