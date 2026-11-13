
--Q6: list all categories in the subtree rooted at 'Computers' at any depth
;with CategoryHierarchy as
(
select category_id,
category_name,
1 as depth_level,
cast(category_name as varchar(max)) as category_path
from dbo.dim_category
where category_name='Computers'

union all

select c.category_id, 
c.category_name,
cte.depth_level+1 as depth_level,
cast(cte.category_path+'->'+ c.category_name as varchar(max)) as category_path
from dbo.dim_category as c join CategoryHierarchy as cte
on c.Parent_category_id=cte.category_id
)
select category_id, category_name,category_path,depth_level
from CategoryHierarchy
option (maxrecursion 100)
Go
