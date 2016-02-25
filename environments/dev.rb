name "dev"
description "The test environment"

override_attributes({
                      "nginx" => {"server_name" => "testname.com"}
                     })

