-- Key entites -----------------------------------------------------------------------
CREATE TABLE Виды_событий (
  ИД serial PRIMARY KEY,
  Наименование text NOT NULL UNIQUE
);

CREATE TABLE Виды_ГО (
  ИД serial PRIMARY KEY,
  Наименование text NOT NULL UNIQUE
);

CREATE TABLE Виды_организаций (
  ИД serial PRIMARY KEY,
  Наименование text NOT NULL UNIQUE
);

CREATE TABLE Роли (
  ИД serial PRIMARY KEY,
  Наименование text NOT NULL UNIQUE
);

CREATE TABLE Религии (
  ИД serial PRIMARY KEY,
  Название text NOT NULL UNIQUE,
  Словесн_опис_символа text,
  Справ_информация text,
  Время_появления varchar(28),
  Время_исчезновения varchar(28)
);

CREATE TABLE Пол (
  ИД serial PRIMARY KEY, 
  Пол text NOT NULL UNIQUE
);

CREATE SEQUENCE acting_entities_id_seq START WITH 1;

CREATE TABLE Действ_сущности (
  ИД integer PRIMARY KEY,
  tblname text NOT NULL CHECK (tblname in ('Дома', 'Организации', 'Действ_лица', 'Типы_действ_лиц'))
);

COMMENT ON TABLE Действ_сущности IS 'Действ_сущности является служебной сущностью, обобщающей сущности Дома, Организации, Действ_лица и Виды_действ_лиц по общему признаку — способности участвовать в событиях. tblname — точное имя сущности, экземпляру которой соответствует данный экземпляр сущности Действ_сущности';
--------------------------------------------------------------------------------

-- Assosications ---------------------------------------------------------------
CREATE TABLE События (
  ИД serial PRIMARY KEY,
  ИД_вида integer NOT NULL REFERENCES Виды_событий,
  Время_начала varchar(28),
  Время_окончания varchar(28),
  Название text NOT NULL UNIQUE,
  Причина text,
  Описание text,
  Итог text
);

CREATE TABLE Участия_в_событиях (
  ИД_события integer REFERENCES События,
  ИД_участника integer REFERENCES Действ_сущности,
  PRIMARY KEY (ИД_события, ИД_участника)
);

CREATE TABLE Организации (
  ИД integer PRIMARY KEY DEFAULT nextval('acting_entities_id_seq'),
  ИД_вида integer NOT NULL REFERENCES Виды_организаций,
  ИД_религии integer REFERENCES Религии,
  Название text NOT NULL UNIQUE,
  Цель text,
  Справ_информация text,
  Время_появления varchar(28),
  Время_исчезновения varchar(28)
);

CREATE TABLE Типы_действ_лиц (
  ИД integer PRIMARY KEY DEFAULT nextval('acting_entities_id_seq'),
  ИД_религии integer REFERENCES Религии,
  Название text NOT NULL UNIQUE,
  Справ_информация text,
  Время_появления varchar(28),
  Время_исчезновения varchar(28)
);

CREATE TABLE Действ_лица (
  ИД integer PRIMARY KEY DEFAULT nextval('acting_entities_id_seq'),
  ИД_ТДЛ integer REFERENCES Типы_действ_лиц,
  ИД_пола integer REFERENCES Пол,
  ИД_владельца integer REFERENCES Действ_лица,
  ИД_религии integer REFERENCES Религии,
  ИД_отца integer REFERENCES Действ_лица,
  ИД_матери integer REFERENCES Действ_лица,
  Имя text NOT NULL,
  Справ_информация text,
  Время_рождения varchar(28),
  Время_смерти varchar(28)
);

CREATE TABLE Дома (
  ИД integer PRIMARY KEY DEFAULT nextval('acting_entities_id_seq'),
  ИД_сюзерена integer REFERENCES Дома,
  ИД_религии integer REFERENCES Религии,
  Название text NOT NULL UNIQUE,
  Описание_герба text NOT NULL UNIQUE,
  Девиз text UNIQUE NOT NULL,
  Справ_информация text,
  Великий_ли boolean NOT NULL,
  Время_появления varchar(28),
  Время_исчезновения varchar(28)
);

CREATE TABLE Гео_объекты (
  ИД serial PRIMARY KEY,
  ИД_дома_владельца integer REFERENCES Дома,
  ИД_род_замок_для integer UNIQUE REFERENCES Дома,
  ИД_правителя integer REFERENCES Действ_лица,
  ИД_столицы integer UNIQUE REFERENCES Гео_объекты,
  ИД_вида integer REFERENCES Виды_ГО,
  Название text NOT NULL UNIQUE,
  Справ_информация text,
  Время_появления varchar(28),
  Время_исчезновения varchar(28)
);

CREATE TABLE Включения_ГО (
  ИД_ГО_вход integer REFERENCES Гео_объекты,
  ИД_ГО_включ integer REFERENCES Гео_объекты,
  PRIMARY KEY (ИД_ГО_вход, ИД_ГО_включ)
);

CREATE TABLE Места_происш (
  ИД_события integer REFERENCES События,
  ИД_места integer REFERENCES Гео_объекты,
  PRIMARY KEY (ИД_события, ИД_места)
);

CREATE TABLE Выходы_к_морям (
  ИД_земли integer REFERENCES Гео_объекты,
  ИД_моря integer REFERENCES Гео_объекты,
  PRIMARY KEY (ИД_земли, ИД_моря)
);

CREATE TABLE Обитания (
  ИД_ТДЛ integer REFERENCES Типы_действ_лиц,
  ИД_земли integer REFERENCES Гео_объекты,
  PRIMARY KEY (ИД_ТДЛ, ИД_земли)
);

CREATE TABLE Участия_в_орг (
  ИД_орг integer REFERENCES Организации,
  ИД_участника integer REFERENCES Действ_лица,
  ИД_роли integer REFERENCES Роли,
  PRIMARY KEY (ИД_орг, ИД_участника, ИД_роли)
);

CREATE TABLE Принадл_к_дому (
  ИД_дома integer REFERENCES Дома,
  ИД_участника integer REFERENCES Действ_лица,
  ИД_роли integer REFERENCES Роли,
  PRIMARY KEY (ИД_дома, ИД_участника, ИД_роли)
);
--------------------------------------------------------------------------------

-- Characteristics -------------------------------------------------------------
CREATE TABLE Боги (
  Имя text PRIMARY KEY,
  ИД_религии integer NOT NULL REFERENCES Религии,
  Справ_информация text
);

CREATE TABLE Артефакты (
  Название text PRIMARY KEY,
  ИД_владельца integer REFERENCES Действ_лица,
  Справ_информация text
);
--------------------------------------------------------------------------------

-- Enforcing indexes ---------------------------------------------------------------------
CREATE UNIQUE INDEX Виды_событий_наименование_unidx ON Виды_событий (lower(Наименование));
CREATE UNIQUE INDEX Виды_ГО_наименование_unidx ON Виды_ГО (lower(Наименование));
CREATE UNIQUE INDEX Виды_организаций_наименование_unidx ON Виды_организаций (lower(Наименование));
CREATE UNIQUE INDEX Роли_наименование_unidx ON Роли (lower(Наименование));
CREATE UNIQUE INDEX Религии_название_unidx ON Религии (lower(Название));
CREATE UNIQUE INDEX Пол_пол_unidx ON Пол (lower(Пол));
CREATE UNIQUE INDEX События_название_unidx ON События (lower(Название));
CREATE UNIQUE INDEX Организации_название_unidx ON Организации (lower(Название));
CREATE UNIQUE INDEX Типы_действ_лиц_название_unidx ON Типы_действ_лиц (lower(Название));
CREATE UNIQUE INDEX Гео_объекты_название_unidx ON Гео_объекты (lower(Название));
CREATE UNIQUE INDEX Боги_имя_unidx ON Боги (lower(Имя));
CREATE UNIQUE INDEX Артефакты_название_unidx ON Артефакты (lower(Название));
--------------------------------------------------------------------------------