CALL dbms.cluster.overview();

CREATE (:POCTest {name:'node1'});
CREATE (:POCTest {name:'node2'});

MATCH (n:POCTest) RETURN n;

UNWIND range(1,20) AS id CREATE (:LoadTest {id:id});

MATCH (n:LoadTest) RETURN count(n);
