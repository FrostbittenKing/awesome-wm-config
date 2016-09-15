AWESOME_HOME=${HOME}/.config/awesome

all : install

install :
	mkdir -p ${AWESOME_HOME}
	cp -a . ${AWESOME_HOME}
