delete from command_data;
delete from command;
delete from parameter;

alter sequence command_id_seq restart;



insert into parameter (id, name)
values 

    ('average_speed_time', 'Средняя скорость считается за столько миллисекунд'),
    ('timeout', 'Таймаут сетевого соединения, в миллисекундах'),
    -- GPS-related
    ('gps_idle_interval', 'Интервал соединения с сервером при отсутствии данных от GPS, в миллисекундах'),
    ('gps_time','Интервал запроса данных с GPS-приёмника, в миллисекундах'),
    ('gps_distance','Запрос данных при изменении координат на столько метров'),
    ('gps_satellites','минимальное кол-во спутников для приёма информации, шт'),
    ('gps_accuracy','точность определения коорлинат, в метрах, не хуже чем это значение (20 - нормально)'),
    ('spdn', 'Количество данных с GPS-приёмника для получения усреднённой скорости, шт.'),
    ('param_update', 'Время между обновлениями параметров, миллисекунд'),
    ('state', 'Состояние устройства: 0 - хорошо, 1 — поломато 1 тип, 2 — поломато 2 тип'),
    
    ('max_spd', 'Скорость, которая считается "максимальной", при превышении которой машина ломается, км/ч'),
    ('fuel', 'Количество топлива, в абстрактных единицах'),
    ('max_fuel', 'Максимальное количество топлива, в абстрактных единицах'),
    ('fuel_per_km', 'Расход топлива на километр, в абстрактных единицах'),
    ('reliability', 'Надёжность — кол-во потери хитов на километр пробега'),
    ('hit_points', 'Хиты'),
    ('max_hit_points', 'Максимальные хиты'),
    ('red_zone', '"Красная зона", в км/ч'),
    ('damage_resistance', 'Броня, сопротивляемость поражениям, в хитах'),
    ('p1_formula', 'Формула для вычисления вероятности поломки первого типа'),
    ('p2_formula', 'Формула для вычисления вероятности поломки второго типа'),
    ('malfunction_interval', 'раз в такое кол-во МЕТРОВ мы "кидаем кубик" на поломку'),
    ('red_zone_reliability', 'сколько хитов слетает с машины на км при движении в "красной зоне"'),
    ('red_zone_fuel_per_km', 'сколько топлива расходуется на км при движении в "красной зоне"'),
    ('malfunction1_red_zone', '"Красная зона" для поломки 1 типа, пороговое значение, км/ч'),
    ('malfunction1_reliability', 'сколько хитов слетает с машины на км при поломке 1 типа'),
    ('malfunction1_fuel_per_km', 'сколько топлива расходуется на км при движении при поломке 1 типа'),
    ('malfunction1_red_zone_reliability', 'сколько хитов слетает с машины на км при движении в "красной зоне" при поломке 1 типа'),
    ('malfunction1_red_zone_fuel_per_km', 'сколько топлива расходуется на км при движении в "красной зоне" при поломке 1 типа');

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

