---------------
-- CENSO 2010 
---------------
drop table if exists preprocess.dictionary_censo_2010;
create table preprocess.dictionary_censo_2010 (dictionary json);

-- set path for dictionary of column names for censo 2010
\set dictionary_2010_path :path '/dictionary_2010.json'
-- copy the dictionary into the table preprocess.dictionary_censo_2010
COPY preprocess.dictionary_censo_2010 from :'dictionary_2010_path';
-- replace columns from json
select replace_cols_from_json(
       (select dictionary from preprocess.dictionary_censo_2010),
               'ageb_zm_2010' ,
         	'preprocess');
-- for iter 2010
select replace_cols_from_json(
	(select dictionary from preprocess.dictionary_censo_2010),
	          'iter_2010',
		  'preprocess');

---------------
-- CENSO 2005
--------------
drop table if exists preprocess.dictionary_censo_2005;
create table preprocess.dictionary_censo_2005 (dictionary json);

-- set path for dictionary of column names for censo 2005
\set dictionary_2005_path :path '/dictionary_2005.json'
-- copy the dictionary into the table preprocess.dictionary_censo_2005
COPY preprocess.dictionary_censo_2005 from :'dictionary_2005_path';
-- replace columns from json
select replace_cols_from_json(
	(select dictionary from preprocess.dictionary_censo_2005),
	'ageb_zm_2005',
	'preprocess');
-- for iter 2005
select replace_cols_from_json(
	(select dictionary from preprocess.dictionary_censo_2005),
	        'iter_2005',
		'preprocess');

--------------
-- CENSO 2000
--------------
-- Urbano
drop table if exists preprocess.dictionary_censo_2000;
create table preprocess.dictionary_censo_2000 (dictionary json);

-- set path for dictionary of column names for censo 2000
\set dictionary_2000_path :path '/dictionary_2000.json'
-- copy the dictionary into the table preprocess.dictionary_censo_2000
COPY preprocess.dictionary_censo_2000 from :'dictionary_2000_path';
-- replace columns from json
select replace_cols_from_json(
	(select dictionary from preprocess.dictionary_censo_2000),
	'ageb_zm_2000',
	'preprocess');


-- For iter 2000
drop table if exists preprocess.dictionary_2000_iter;
create table preprocess.dictionary_2000_iter (dictionary json);

 -- set path for dictionary of column names for iter 2000
\set dictionary_2000_iter_path :path '/dictionary_2000_iter.json'
-- copy the dictionary into the table preprocess.dictionary_2000_iter
COPY preprocess.dictionary_2000_iter from :'dictionary_2000_iter_path';
-- replace columns from json for iter
 select replace_cols_from_json(
	(select dictionary from preprocess.dictionary_2000_iter),
	'iter_2000',
	'preprocess');
