name "appserver"
description "install tomcat jdk and nginx"
run_list(
    "recipe[tomcat]",
    "recipe[nginx]",
    "recipe[java_wrapper]"
)