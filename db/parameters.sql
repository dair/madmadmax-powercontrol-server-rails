delete from command_data;
delete from command;
delete from parameter;

alter sequence command_id_seq restart;



insert into parameter (t, id, name)
values 
    ('T', 'average_speed_time', 'Средняя скорость считается за столько миллисекунд'),
    ('T', 'timeout', 'Таймаут сетевого соединения, в миллисекундах'),
    ('T', 'gps_idle_interval', 'Интервал соединения с сервером при отсутствии данных от GPS, в миллисекундах'),
    ('T', 'gps_time','Интервал запроса данных с GPS-приёмника, в миллисекундах'),
    ('T', 'gps_distance','Запрос данных при изменении координат на столько метров'),
    ('T', 'gps_satellites','минимальное кол-во спутников для приёма информации, шт'),
    ('T', 'gps_accuracy','точность определения коорлинат, в метрах, не хуже чем это значение (20 - нормально)'),
    ('T', 'spdn', 'Количество данных с GPS-приёмника для получения усреднённой скорости, шт.'),
    ('T', 'param_update', 'Время между обновлениями параметров, миллисекунд'),
    ('T', 'damage_code', 'Коды попаданий из ксотаропушки; JSON от 0 до 15'),
    ('T', 'mock_available', 'Доступен режим подстановки данных GPS (для отладки, игроку не надо никакому)'),
    ('G', 'drive2siege_delay', 'Время (мс) переключения из режима езды в режим стрельбы'),
    ('G', 'siege2drive_delay', 'Время (мс) переключения из режима стрельбы в режим езды'),
    ('G', 'state', 'Состояние устройства: 0 - хорошо, 1 — поломато 1 тип, 2 — поломато 2 тип'),
    ('G', 'max_spd', 'Скорость, которая считается "максимальной", при превышении которой машина ломается, км/ч'),
    ('G', 'fuel', 'Количество топлива, в абстрактных единицах'),
    ('G', 'max_fuel', 'Максимальное количество топлива, в абстрактных единицах'),
    ('G', 'fuel_per_km', 'Расход топлива на километр, в абстрактных единицах'),
    ('G', 'reliability', 'Надёжность — кол-во потери хитов на километр пробега'),
    ('G', 'hit_points', 'Хиты'),
    ('G', 'max_hit_points', 'Максимальные хиты'),
    ('G', 'red_zone', '"Красная зона", в км/ч'),
    ('G', 'damage_resistance', 'Броня, сопротивляемость поражениям, в хитах'),
    ('G', 'p1_formula', 'Формула для вычисления вероятности поломки первого типа'),
    ('G', 'p2_formula', 'Формула для вычисления вероятности поломки второго типа'),
    ('G', 'malfunction_interval', 'раз в такое кол-во МЕТРОВ мы "кидаем кубик" на поломку'),
    ('G', 'red_zone_reliability', 'сколько хитов слетает с машины на км при движении в "красной зоне"'),
    ('G', 'red_zone_fuel_per_km', 'сколько топлива расходуется на км при движении в "красной зоне"'),
    ('G', 'malfunction1_red_zone', '"Красная зона" для поломки 1 типа, пороговое значение, км/ч'),
    ('G', 'malfunction1_reliability', 'сколько хитов слетает с машины на км при поломке 1 типа'),
    ('G', 'malfunction1_fuel_per_km', 'сколько топлива расходуется на км при движении при поломке 1 типа'),
    ('G', 'malfunction1_red_zone_reliability', 'сколько хитов слетает с машины на км при движении в "красной зоне" при поломке 1 типа'),
    ('G', 'malfunction1_red_zone_fuel_per_km', 'сколько топлива расходуется на км при движении в "красной зоне" при поломке 1 типа');

insert into command (device_id, user_name) values (NULL, 'admin');
insert into command (device_id, user_name) values (NULL, 'admin');
insert into command_data (id, param_id, value) values
    (1, 'average_speed_time', '30000'),
    (1, 'timeout', '30000'),
    (1, 'gps_idle_interval', '5000'),
    (1, 'gps_time', '2000'),
    (1, 'gps_distance', '50'),
    (1, 'gps_satellites', '3'),
    (1, 'gps_accuracy', '32'),
    (1, 'spdn', '5'),
    (1, 'param_update', '10000'),
    (1, 'state', '0'),

    (1, 'max_spd', '40'),
    (1, 'fuel', '0'),
    (1, 'max_fuel', '1000'),
    (1, 'fuel_per_km', '20'),
    (1, 'reliability', '1'),
    (1, 'hit_points', '100'),
    (1, 'max_hit_points', '100'),
    (1, 'red_zone', '25'),
    (1, 'damage_resistance', '0'),
    (1, 'p1_formula', '1-(4*x/3)^0.3'),
    (1, 'p2_formula', '1-(2*x)^0.3'),
    (1, 'malfunction_interval', '100'),
    (1, 'red_zone_reliability', '3'),
    (1, 'red_zone_fuel_per_km', '500'),
    (1, 'malfunction1_red_zone', '15'),
    (1, 'malfunction1_reliability', '2'),
    (1, 'malfunction1_fuel_per_km', '300'),
    (1, 'malfunction1_red_zone_reliability', '6'),
    (1, 'malfunction1_red_zone_fuel_per_km', '1000');

