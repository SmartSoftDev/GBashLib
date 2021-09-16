
#Functii care faciliteaza lucru cu postgres
#cum se importa:
#. $G_BASH_LIB/libs/postgres.lib.bsh

function pg_database_exists(){
	local database="$1"
	if ! sudo -u postgres psql -A -t -c "SELECT datname FROM pg_database" | grep -e "^${database}$" >/dev/null 2>/dev/null ; then
		return 1
	else
		return 0
	fi
}

function pg_user_exists(){
	local user="$1"

	if [ "$(sudo -u postgres psql -A -t -c "SELECT 1 FROM pg_roles WHERE rolname='$user' ; ")" == "1" ] ; then
		return 0
	else
		return 1
	fi
}

function pg_create_user_and_database(){
	local user="$1"
	local password="$2"
	local database="$3"
	sudo -u postgres psql -c  "CREATE DATABASE \"$database\";"
	sudo -u postgres psql -c  "\
		CREATE USER \"$user\" WITH PASSWORD \"$password\"; \
		GRANT ALL PRIVILEGES ON DATABASE \"$database\" to \"$user\";"
	sudo -u postgres psql "$database" -c  "\
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO \"$user\" WITH GRANT OPTION;\
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO \"$user\" WITH GRANT OPTION;"
}

function pg_create_admin_user_and_database(){
	local user="$1"
	local password="$2"
	local database="$3"
	sudo -u postgres psql -c  "CREATE ROLE \"$user\" WITH LOGIN PASSWORD '$password';"
	sudo -u postgres psql "template1" -c  "ALTER USER \"$user\" CREATEDB CREATEROLE;"
	sudo -u postgres psql -c  "CREATE DATABASE \"$database\";"
	sudo -u postgres psql -c  "\
		GRANT ALL PRIVILEGES ON DATABASE \"$database\" to \"$user\";"
	sudo -u postgres psql "$database" -c  "\
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO \"$user\" WITH GRANT OPTION;\
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA PUBLIC TO \"$user\" WITH GRANT OPTION;"
}

function pg_create_admin_user(){
	local user="$1"
	local password="$2"
	sudo -u postgres psql -c  "CREATE USER \"$user\" WITH LOGIN PASSWORD \"$password\";"
	sudo -u postgres psql "template1" -c  "ALTER USER \"$user\" CREATEDB CREATEROLE;"
}

function pg_drop_user(){
	local user="$1"
	sudo -u postgres psql -c  "\
		DROP USER \"$user\";"
}

function pg_drop_database(){
	local database="$1"
	#kill all connections to database FIRST
	sudo -u postgres psql -c  "\
	SELECT pg_terminate_backend(pg_stat_activity.pid) \
	FROM pg_stat_activity \
	WHERE pg_stat_activity.datname ='$database' \
  	AND pid <> pg_backend_pid();"
	sudo -u postgres dropdb "$database"
}


function pg_exec(){
	local database="$1"
	local filePath="$2"
	sudo -u postgres psql "$database" < "$filePath"
}
