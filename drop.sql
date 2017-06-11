-- Key entities ---------------------------
DROP TABLE IF EXISTS Виды_событий CASCADE;
DROP TABLE IF EXISTS Виды_ГО CASCADE;
DROP TABLE IF EXISTS Действ_сущности CASCADE;
DROP TABLE IF EXISTS Виды_организаций CASCADE;
DROP TABLE IF EXISTS Роли CASCADE;
DROP TABLE IF EXISTS Пол CASCADE;
DROP TABLE IF EXISTS Религии CASCADE;
-------------------------------------------

-- Associations ---------------------------
DROP TABLE IF EXISTS Гео_объекты CASCADE;
DROP TABLE IF EXISTS Дома CASCADE;
DROP TABLE IF EXISTS Обитания CASCADE;
DROP TABLE IF EXISTS Выходы_к_морям CASCADE;
DROP TABLE IF EXISTS Включения_ГО CASCADE;
DROP TABLE IF EXISTS Участия_в_орг CASCADE;
DROP TABLE IF EXISTS Принадл_к_дому CASCADE;
DROP TABLE IF EXISTS Участия_в_событиях CASCADE;
DROP TABLE IF EXISTS Места_происш CASCADE;
DROP TABLE IF EXISTS Организации CASCADE;
DROP TABLE IF EXISTS События CASCADE;
DROP TABLE IF EXISTS Типы_действ_лиц CASCADE;
DROP TABLE IF EXISTS Действ_лица CASCADE;
-------------------------------------------

-- Charactistics --------------------------
DROP TABLE IF EXISTS Артефакты CASCADE;
DROP TABLE IF EXISTS Боги CASCADE;
-------------------------------------------

DROP SEQUENCE IF EXISTS acting_entities_id_seq;