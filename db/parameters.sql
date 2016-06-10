insert into parameter (id, name)
values 
    ('timeout', 'Таймаут сетевого соединения, в миллисекундах'),
    -- GPS-related
    ('gps_idle_interval', 'Интервал соединения с сервером при отсутствии данных от GPS, в миллисекундах'),
    ('gps_time','Интервал запроса данных с GPS-приёмника, в миллисекундах'),
    ('gps_distance','Запрос данных при изменении координат на столько метров'),
    ('gps_satellites','минимальное кол-во спутников для приёма информации, шт'),
    ('spdn', 'Количество данных с GPS-приёмника для получения усреднённой скорости, шт.'),
    ('param_update', 'Время между обновлениями параметров, миллисекунд'),
    ('state', 'Состояние устройства: 0 - хорошо, 1 — поломато'),
    
    ('max_spd', 'Скорость, которая считается "максимальной", при превышении которой машина ломается, км/ч'),
    ('fuel', 'Количество топлива, в абстрактных единицах'),
    ('max_fuel', 'Максимальное количество топлива, в абстрактных единицах'),
    ('fuel_per_km', 'Расход топлива на километр, в абстрактных единицах');

insert into command (id, device_id, user_name) values (1, NULL, 'admin');
insert into command_data (id, param_id, value) values
    (1, 'timeout', '30000'),
    (1, 'gps_idle_interval', '5000'),
    (1, 'gps_time', '2000'),
    (1, 'gps_distance', '50'),
    (1, 'gps_satellites', '3'),
    (1, 'spdn', '5'),
    (1, 'param_update', '10000'),
    (1, 'state', '0'),

    (1, 'max_spd', '40'),
    (1, 'fuel', '0'),
    (1, 'max_fuel', '1000'),
    (1, 'fuel_per_km', '20');
