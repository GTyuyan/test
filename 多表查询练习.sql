/*
1. 查出至少有一个员工的部门。显示部门编号、部门名称、部门位置、部门人数。
列：d.deptno, d.dname, d.loc, 部门人数
表：dept d, emp e
条件：e.deptno=d.deptno
*/
-- 主表简化，内连接，去笛卡尔积

SELECT d.*,z1.人数
FROM dept d ,(SELECT deptno,COUNT(*) 人数 FROM emp GROUP BY deptno) z1
WHERE d.deptno=z1.deptno;


/*
3. 列出所有员工的姓名及其直接上级的姓名。
列：员工姓名、上级姓名
表：emp e, emp m
条件：员工的mgr = 上级的empno
*/
-- ok
SELECT e.ename,z1.ename
FROM emp e,(SELECT e.empno,e.ename FROM emp e) z1
WHERE e.mgr=z1.empno;
-- ok
SELECT e.ename,z1.ename
FROM emp e,(SELECT empno,ename FROM emp) z1
WHERE e.mgr=z1.empno;


-- 答案
SELECT e.ename,IFNULL(m.ename,'boss') 领导
FROM emp e LEFT OUTER JOIN emp m 
ON e.mgr=m.empno;


/*
4. 列出受雇日期早于直接上级的所有员工的编号、姓名、部门名称。
列：e.empno, e.ename, d.dname
表：emp e, emp m, dept d
条件：e.hiredate<m.hiredate
思路：
1. 先不查部门名称，只查部门编号!
列：e.empno, e.ename, e.deptno
表：emp e, emp m
条件：e.mgr=m.empno, e.hiredate<m.hireadate
*/
-- Duplicate column name 'empno'
SELECT z1.empno,z1.ename,z1.deptno
FROM (SELECT *FROM emp e,emp m
WHERE e.mgr=m.empno AND e.hiredate<m.hiredate) z1,dept d
WHERE z1.deptno=d.deptno;

-- Duplicate column name 'empno'

SELECT z1.empno,z1.ename,z1.deptno
FROM dept d,(SELECT * FROM emp e,emp m WHERE e.mgr=m.empno AND e.hiredate<m.hiredate) z1
WHERE z1.deptno=d.deptno;

-- ok 
-- 子查找，查询结果中不能有两个主键
SELECT z1.empno,z1.ename,z1.deptno
FROM dept d,(SELECT e.empno,e.ename,e.deptno FROM emp e,emp m WHERE e.mgr=m.empno AND e.hiredate<m.hiredate) z1
WHERE z1.deptno=d.deptno;

-- 答案
SELECT e.empno,e.ename,d.dname
FROM emp e,emp m,dept d
WHERE e.mgr=m.empno AND e.hiredate<m.hiredate AND e.deptno=d.deptno

/*
5. 列出部门名称和这些部门的员工信息，同时列出那些没有员工的部门。
列：* 
表：emp e, dept d
条件：e.deptno=d.deptno
*/

SELECT e.*,d.dname
FROM emp e RIGHT OUTER JOIN dept d
ON e.deptno=d.deptno
UNION
SELECT e.*,d.dname
FROM emp e LEFT OUTER JOIN dept d
ON e.deptno=d.deptno

-- 答案
SELECT e.*,d.dname
FROM emp e RIGHT OUTER JOIN dept d
ON e.deptno=d.deptno

/*
7. 列出最低薪金大于15000的各种工作及从事此工作的员工人数。
列：job, count(*)
表：emp e
条件：min(sal) > 15000
分组：job
*/

SELECT job,COUNT(*) 
FROM emp
GROUP BY job 
HAVING MIN(sal)>15000



/*
8. 列出在销售部工作的员工的姓名，假定不知道销售部的部门编号。
列：e.ename
表：emp
条件：e.deptno=(select deptno from dept where dname='销售部')
*/
SELECT e.ename
FROM emp e
WHERE e.deptno=(SELECT deptno FROM dept WHERE dname='销售部')


/*
9. 列出薪金高于公司平均薪金的所有员工信息，所在部门名称，上级领导，工资等级。
列：* 
表：emp e
条件：sal>(查询出公司的平均工资)
*/

SELECT * FROM salgrade;
-- 报错,Invalid use of group function

SELECT *
FROM emp 
WHERE sal>AVG(sal)
-- 改为
SELECT *
FROM emp 
WHERE sal>(SELECT AVG(sal) FROM emp)


SELECT e.*,d.dname,m.ename,s.grade
FROM emp e ,dept d,emp m, salgrade s
WHERE e.sal>(SELECT AVG(sal) FROM emp)AND e.deptno=d.deptno 
AND e.mgr=m.empno AND e.sal BETWEEN s.losal AND s.hisal

-- 答案 --何时取别名，何时使用集合函数
-- 随时可以取别名，当使用子查询结果时一定要取别名
-- 分组后可使用集合函数，集合函数是一种查询结果，要用select得到
-- 左外连接时，对左表的的筛选不能放在去笛卡尔积条件里，否则无效
-- 不是对分组结果操作均可使用where子句
SELECT e.*,d.dname,m.ename,s.grade
FROM emp e 
LEFT OUTER JOIN dept d ON e.sal>(SELECT AVG(sal) FROM emp)AND e.deptno=d.deptno
LEFT OUTER JOIN emp m ON e.mgr=m.empno
LEFT OUTER JOIN salgrade s ON e.sal BETWEEN s.losal AND s.hisal

SELECT e.*,d.dname
FROM emp e 
LEFT OUTER JOIN dept d ON e.sal>(SELECT AVG(sal) FROM emp)AND e.deptno=d.deptno



-- 答案
-- WHERE 关键字无法与合计函数一起使用
SELECT e.*,d.dname,m.ename,s.grade
FROM emp e 
LEFT OUTER JOIN dept d ON  e.deptno=d.deptno
LEFT OUTER JOIN emp m ON e.mgr=m.empno
LEFT OUTER JOIN salgrade s ON e.sal BETWEEN s.losal AND s.hisal
WHERE e.sal>(SELECT AVG(sal) FROM emp)
/*
10.列出与庞统从事相同工作的所有员工及部门名称。 
列：e.*, d.dname
表：emp e, dept d
条件：job=(查询出庞统的工作) 
*/

SELECT e.*,d.dname
FROM emp e,dept d
WHERE e.deptno=d.deptno AND job=(SELECT job FROM emp WHERE ename='庞统')


/*
11.列出薪金高于在部门30工作的所有员工的薪金　的员工姓名和薪金、部门名称。
列：e.ename, e.sal, d.dname
表：emp e, dept d
条件；sal>all (30部门薪金)
*/
-- 答案
SELECT e.ename,e.sal,d.dname
FROM emp e,dept d
WHERE e.deptno=d.deptno AND e.sal>ALL(SELECT sal FROM emp WHERE deptno=30)


SELECT e.ename,e.sal,d.dname
FROM emp e,dept d
WHERE e.deptno=d.deptno AND e.sal>(SELECT MAX(sal) FROM emp WHERE deptno=30)
/*
13.查出年份、利润、年度增长比
*/



