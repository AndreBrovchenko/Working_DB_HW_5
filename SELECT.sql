-- ------------------------------------------------------
-- 1.количество исполнителей в каждом жанре
-- ------------------------------------------------------
SELECT g.genre_name, COUNT(s.singer_name) count_singer
FROM genres g
JOIN performergenres p ON g.id_genre = p.id_genre 
JOIN singers s ON p.id_singer = s.id_singer 
GROUP BY g.genre_name
ORDER BY g.genre_name;
-- ------------------------------------------------------
-- 2.количество треков, вошедших в альбомы 2019-2020 годов
-- ------------------------------------------------------
SELECT a.album_name, a.year_issue_album, COUNT(t.track_name) count_track
FROM tracks t 
JOIN albums a ON t.id_album = a.id_album
WHERE a.year_issue_album between 2019 and 2020
GROUP BY a.album_name, a.year_issue_album
ORDER BY a.album_name;
-- ------------------------------------------------------
-- 3.средняя продолжительность треков по каждому альбому
-- ------------------------------------------------------
SELECT a.album_name, AVG(t.track_duration) avg_track_duration 
FROM albums a
JOIN tracks t ON a.id_album = t.id_album 
GROUP BY a.album_name
ORDER BY a.album_name;
-- ------------------------------------------------------
-- 4.все исполнители, которые не выпустили альбомы в 2020 году
-- ------------------------------------------------------
SELECT s.singer_name
FROM singers s 
JOIN albumartists aa ON s.id_singer = aa.id_singer 
JOIN albums a ON aa.id_album = a.id_album 
WHERE a.year_issue_album != 2020
GROUP BY s.singer_name
ORDER BY s.singer_name;
-- ------------------------------------------------------
-- 5.названия сборников, в которых присутствует конкретный исполнитель (выберите сами)
-- ------------------------------------------------------
SELECT ac.album_collection_name, s.singer_name FROM albumcollections ac
JOIN trackcollections tc ON ac.id_album_collection = tc.id_album_collection 
JOIN tracks t ON tc.id_track = t.id_track 
JOIN albums a ON t.id_album = a.id_album 
JOIN albumartists aa ON a.id_album = aa.id_album 
JOIN singers s ON aa.id_singer = s.id_singer 
WHERE LOWER(s.singer_name) = 'михаил круг'
GROUP BY ac.album_collection_name, s.singer_name;
-- ------------------------------------------------------
-- 6.название альбомов, в которых присутствуют исполнители более 1 жанра
-- ------------------------------------------------------
SELECT a.album_name, COUNT(g.genre_name) count_genre FROM albums a 
JOIN albumartists aa ON a.id_album = aa.id_album 
JOIN singers s ON aa.id_singer = s.id_singer 
JOIN performergenres p ON s.id_singer = p.id_singer 
JOIN genres g ON p.id_genre = g.id_genre 
GROUP BY a.album_name 
HAVING COUNT(g.genre_name) > 1
ORDER BY a.album_name;
-- ------------------------------------------------------
-- 7.наименование треков, которые не входят в сборники
-- ------------------------------------------------------
SELECT t.track_name FROM tracks t 
LEFT JOIN trackcollections tc ON t.id_track = tc.id_track
WHERE tc.id_track is NULL;
-- ------------------------------------------------------
-- 8.исполнителя(-ей), написавшего самый короткий по продолжительности трек
-- ------------------------------------------------------
SELECT s.singer_name, t.track_duration FROM singers s 
JOIN albumartists aa ON s.id_singer = aa.id_singer 
JOIN albums a ON aa.id_album = a.id_album 
JOIN tracks t ON a.id_album = t.id_album
WHERE t.track_duration = (SELECT MIN(t.track_duration) FROM tracks t);
-- ------------------------------------------------------
-- 9.название альбомов, содержащих наименьшее количество треков
--   вариант 1 -> Применение предиката ALL в секции HAVING
-- ------------------------------------------------------
SELECT ac.album_collection_name, COUNT(t.track_name) 
FROM albumcollections ac 
JOIN trackcollections tc ON ac.id_album_collection = tc.id_album_collection 
JOIN tracks t ON t.id_track = tc.id_track
GROUP BY ac.album_collection_name
HAVING COUNT(t.track_name) <= ALL
	(SELECT COUNT(t.track_name) 
	FROM albumcollections ac 
	JOIN trackcollections tc ON ac.id_album_collection = tc.id_album_collection 
	JOIN tracks t ON t.id_track = tc.id_track
	GROUP BY ac.album_collection_name)
;
-- ------------------------------------------------------
-- 9.название альбомов, содержащих наименьшее количество треков
--   вариант 2 -> Применение соединения (JOIN) с условием
-- ------------------------------------------------------
SELECT album_collection_name, count_track
FROM (
	SELECT ac.album_collection_name, COUNT(t.track_name) count_track
	FROM albumcollections ac 
	JOIN trackcollections tc ON ac.id_album_collection = tc.id_album_collection 
	JOIN tracks t ON t.id_track = tc.id_track
	GROUP BY ac.album_collection_name) A
JOIN (
	SELECT MIN(count_track) min_track
	FROM (
		SELECT ac.album_collection_name, COUNT(t.track_name) count_track
		FROM albumcollections ac 
		JOIN trackcollections tc ON ac.id_album_collection = tc.id_album_collection 
		JOIN tracks t ON t.id_track = tc.id_track
		GROUP BY ac.album_collection_name) A
	) B on count_track = min_track
;
-- ------------------------------------------------------
