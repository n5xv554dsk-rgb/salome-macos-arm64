(: declare option saxon:output "indent=yes"; :)
<result>
({
for $l in //.
where local-name($l) eq 'name'
return 
concat(data($l),'@,@')
})
</result>
