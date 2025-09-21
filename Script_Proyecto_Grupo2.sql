USE netflix;
-- Parte 1: Conociendo la Data (4 preguntas)
-- 1. ¿Cuántos títulos existen en el catálogo? 

SELECT COUNT(show_id) AS total_titulos
FROM shows;

-- 2. ¿Cuántos tipos de contenido diferentes hay registrados (Movie, TV Show, etc.)?

SELECT COUNT(*) AS CantidadTipos 
FROM ShowType; 

-- 3. ¿Cuántos países distintos están representados en las producciones?
SELECT *
FROM Country;

SELECT COUNT(DISTINCT c.country_id) AS total_paises_representados
FROM Country c
INNER JOIN show_country sc ON c.country_id = sc.country_id;

-- 4. ¿Cuántas clasificaciones de edad (rating) diferentes existen?

SELECT COUNT(*) AS total_clasificaciones
FROM Rating;

-- Parte 2: Consultas de análisis (6 preguntas)
-- 5. ¿Cuál es el país con mayor cantidad de títulos disponibles en el catálogo?
SELECT c.name AS país, COUNT(*) AS total_titulos
FROM shows s
JOIN show_country sc ON s.show_id = sc.show_id
JOIN Country c ON sc.country_id = c.country_id
GROUP BY c.name
ORDER BY total_titulos DESC
LIMIT 1;

-- 6. ¿Cuáles son los 5 géneros más frecuentes en el catálogo?

SELECT *
FROM show_genre;

SELECT 
    g.name AS genero,
    COUNT(sg.show_id) AS frecuencia
FROM Genre g
INNER JOIN show_genre sg ON g.genre_id = sg.genre_id
GROUP BY g.genre_id, g.name
ORDER BY frecuencia DESC
LIMIT 5;

-- 7. ¿Qué clasificación por edad (rating) es la más común en las películas y cuál en las series?

SELECT r.code AS rating_pelicula, COUNT(s.show_id) AS cantidad
FROM shows s
JOIN ShowType st ON s.type_id = st.type_id
JOIN Rating r ON s.rating_id = r.rating_id
WHERE st.name = 'Movie'
GROUP BY r.code
ORDER BY cantidad DESC
LIMIT 1;

-- Para series
SELECT r.code AS rating_serie, COUNT(s.show_id) AS cantidad
FROM shows s
JOIN ShowType st ON s.type_id = st.type_id
JOIN Rating r ON s.rating_id = r.rating_id
WHERE st.name = 'TV Show'
GROUP BY r.code
ORDER BY cantidad DESC
LIMIT 1;

-- 8. ¿Cómo ha cambiado la duración promedio de las películas a lo largo de los años de lanzamiento?
-- Hint: Para la duración en número deben usar: CAST(REGEXP_SUBSTR(s.duration, '^[0-9]+') AS UNSIGNED)

SELECT 
	CONCAT(CAST(AVG(CAST(REGEXP_SUBSTR(s.duration, '^[0-9]+') AS UNSIGNED)) AS UNSIGNED),' min') AS DuraciónPromedio,
    s.release_year AS AñoLanzamiento
FROM shows s
WHERE s.duration LIKE '%min%'
GROUP BY AñoLanzamiento
ORDER BY AñoLanzamiento;

-- 9. ¿Qué país tiene la mayor diversidad de géneros distintos en su catálogo?

SELECT c.name AS country, COUNT(DISTINCT g.genre_id) AS distinct_genres
FROM show_country sc
JOIN Country c ON sc.country_id = c.country_id
JOIN shows s ON sc.show_id = s.show_id
JOIN show_genre sg ON s.show_id = sg.show_id
JOIN Genre g ON sg.genre_id = g.genre_id
GROUP BY c.name
ORDER BY distinct_genres DESC
LIMIT 1;

-- 10. ¿Cuáles es el título más antiguos disponibles en la plataforma? (Usando subqueries)

SELECT title, release_year
FROM shows
WHERE release_year = (
    SELECT MIN(release_year)
    FROM shows
);

-- Parte 3: Preguntas por integrante (5 preguntas)
-- 1. ¿Cuáles son los shows con la mayor diversidad de géneros asignados?
SELECT 
    s.title AS titulo,
    st.name AS tipo_contenido,
    s.release_year AS año_lanzamiento,
    COUNT(sg.genre_id) AS cantidad_generos,
    GROUP_CONCAT(g.name ORDER BY g.name SEPARATOR ' | ') AS todos_los_generos
FROM shows s
INNER JOIN ShowType st ON s.type_id = st.type_id
INNER JOIN show_genre sg ON s.show_id = sg.show_id
INNER JOIN Genre g ON sg.genre_id = g.genre_id
GROUP BY s.show_id, s.title, st.name, s.release_year
ORDER BY cantidad_generos DESC, s.title
LIMIT 5;

-- 2. ¿Cuáles son los 5 géneros con más títulos en todo el catálogo de Netflix?
SELECT 
    g.name AS Genero,
    COUNT(*) AS Total_Titulos
FROM show_genre sg
JOIN Genre g ON sg.genre_id = g.genre_id
GROUP BY g.name
ORDER BY Total_Titulos DESC
LIMIT 5;

-- 3. ¿Cuáles son los 5 títulos de más reciente lanzamiento?
SELECT title, release_year
FROM shows
ORDER BY release_year DESC
LIMIT 5;

-- 4. ¿Cuáles son las 10 películas con mayor duración?
SELECT
	s.title as "Título",
    s.duration as "Duración"
FROM shows s
WHERE type_id = (SELECT type_id FROM ShowType st WHERE st.name = "Movie")
ORDER BY CAST(REGEXP_SUBSTR(s.duration, '^[0-9]+') AS UNSIGNED) DESC
LIMIT 10;

-- 5. ¿Cuáles son los 5 años donde se agregaron la menor cantidad de títulos a la plataforma?
SELECT YEAR(date_added) AS year_added, COUNT(*) AS total_titles
FROM shows
WHERE date_added IS NOT NULL
GROUP BY YEAR(date_added)
ORDER BY total_titles ASC
LIMIT 5;