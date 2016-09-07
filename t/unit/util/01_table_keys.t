use Test::Nginx::Socket::Lua;

repeat_each(3);
plan tests => repeat_each() * 3 * blocks();

no_shuffle();
run_tests();

__DATA__

=== TEST 1: Table with a single k/v pair
--- http_config
init_by_lua_block{
	if (os.getenv("LRW_COVERAGE")) then
		runner = require "luacov.runner"
		runner.tick = true
		runner.init({savestepsize = 50})
		jit.off()
	end
}
--- config
    location = /t {
        content_by_lua '
			local util = require "resty.waf.util"
			local a = { foo = "bar" }
			local b = util.table_keys(a)
			table.sort(b)
			for i in ipairs(b) do
				ngx.say(b[i])
			end
		';
	}
--- request
GET /t
--- error_code: 200
--- response_body
foo
--- no_error_log
[error]

=== TEST 2: Table with multiple k/v pairs
--- http_config
init_by_lua_block{
	if (os.getenv("LRW_COVERAGE")) then
		runner = require "luacov.runner"
		runner.tick = true
		runner.init({savestepsize = 50})
		jit.off()
	end
}
--- config
    location = /t {
        content_by_lua '
			local util = require "resty.waf.util"
			local a = { foo = "bar", baz = "bat", qux = "frob" }
			local b = util.table_keys(a)
			table.sort(b)
			for i in ipairs(b) do
				ngx.say(b[i])
			end
		';
	}
--- request
GET /t
--- error_code: 200
--- response_body
baz
foo
qux
--- no_error_log
[error]

=== TEST 3: Table with nested k/v pairs
--- http_config
init_by_lua_block{
	if (os.getenv("LRW_COVERAGE")) then
		runner = require "luacov.runner"
		runner.tick = true
		runner.init({savestepsize = 50})
		jit.off()
	end
}
--- config
    location = /t {
        content_by_lua '
			local util = require "resty.waf.util"
			local a = { foo = { "bar", "baz", "bat" }, qux = { "frob" } }
			local b = util.table_keys(a)
			table.sort(b)
			for i in ipairs(b) do
				ngx.say(b[i])
			end
		';
	}
--- request
GET /t
--- error_code: 200
--- response_body
foo
qux
--- no_error_log
[error]

=== TEST 4: Table with redundant keys
--- http_config
init_by_lua_block{
	if (os.getenv("LRW_COVERAGE")) then
		runner = require "luacov.runner"
		runner.tick = true
		runner.init({savestepsize = 50})
		jit.off()
	end
}
--- config
    location = /t {
        content_by_lua '
            local util = require "resty.waf.util"
            local a = { foo = "bar", foo = "baz" }
            local b = util.table_keys(a)
			table.sort(b)
            for i in ipairs(b) do
                ngx.say(b[i])
            end
        ';
    }
--- request
GET /t
--- error_code: 200
--- response_body
foo
--- no_error_log
[error]

=== TEST 5: Not a table
--- http_config
init_by_lua_block{
	if (os.getenv("LRW_COVERAGE")) then
		runner = require "luacov.runner"
		runner.tick = true
		runner.init({savestepsize = 50})
		jit.off()
	end
}
--- config
    location = /t {
        content_by_lua '
			local util = require "resty.waf.util"
			local a = "foo, bar"
			local b = util.table_keys(a)
			table.sort(b)
			for i in ipairs(b) do
				ngx.say(b[i])
			end
		';
	}
--- request
GET /t
--- error_code: 500
--- error_log
fatal_fail
was given to table_keys!

