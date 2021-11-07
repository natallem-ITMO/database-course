update Students
set GroupId = (select GroupId from Groups where GroupName = :GroupName)
where GroupId = (select a.GroupId as GroupId
                 from Groups a cross join Groups b
                 where a.GroupName = :FromGroupName and b.GroupName = :GroupName)