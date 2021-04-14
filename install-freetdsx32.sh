#!/usr/bin/bash

# Small script for installing FreeTDS (with gperf) and unixODBC for 32-bit environment. The resources file of this package contains zip archives of everything that will be installed
# unixODBC is a database driver manager used for managing database connections. See http://www.unixodbc.org/ for more info
# gperf is a hashing generator and is a core dependency of FreeTDS. Script assumes environment requiring manual installation. See https://www.gnu.org/software/gperf for more info
# FreeTDS is an open source database driver that can be configured to work with SQL Server. See https://github.com/FreeTDS/freetds for more info

# Fail on errors
set -e

# set-up directory definitions
PARENT_DIR=$(dirname $(readlink -f $0))
RSRC_DIR=${PARENT_DIR}/resources

# directories script creates - default is the parent directory, otherwise is user specified
MAIN_DIR=${PARENT_DIR}/FREETDS
INSTALL_DIR=${MAIN_DIR}/INSTALL
LIBS_DIR=${MAIN_DIR}/LIBS
LOGS_DIR=${LIBS_DIR}/BUILD_LOGS
FREETDS_DIR=${INSTALL_DIR}/freetds-7.4x32
GPERF_DIR=${INSTALL_DIR}/gperf-3.1x32
ODBC_DIR=${INSTALL_DIR}/unixODBC-2.3.9x32

# function definitions
function run_install() {
	echo "========== Prepping FREETDS install directories =========="
	mkdir ${MAIN_DIR} ${INSTALL_DIR} ${LIBS_DIR} ${LOGS_DIR} ${FREETDS_DIR} ${GPERF_DIR} ${ODBC_DIR}
	echo "Install dircteory: ${INSTALL_DIR}"
	echo "Library directory: ${LIBS_DIR}"
	echo "Logs directory: ${LOGS_DIR}"
	echo "Source directories:"
	echo "$(tree ${INSTALL_DIR})"

	echo "========== Configuring and Building the unixODBC Driver Manager =========="
	install_unixODBC

	echo "========== Configuring and Building gperf (hash function generator) =========="
	install_gperf

	echo "========== Configuring and Building FreeTDS Database Driver =========="
	install_freetds

	echo "========== Configuring unixODBC to use FreeTDS =========="
	#configure_odbc

	echo "INSTALLATION COMPLETE!"
	echo "Please verify the installation using command: ${PARENT_DIR}/test-freetdsx32.sh"
}

function install_unixODBC() {
	cd ${LIBS_DIR}
	echo "Extracting ${RSRC_DIR}/unixODBC-2.3.9.tar.gz under ${LIBS_DIR}..."
	tar -xzf ${RSRC_DIR}/unixODBC-2.3.9.tar.gz
	cd unixODBC-2.3.9
	echo "Begin configuring unixODBC-2.3.9..."
	./configure CFLAGS=-m32 --prefix=${ODBC_DIR} --disable-gui --disable-drivers --enable-iconv 1> ${LOGS_DIR}/unix_odbc_config.log 2> ${LOGS_DIR}/unix_odbc_config.err
	echo "Configuartion complete"
	echo "Building and installing unixODBC-2.3.9 under ${ODBC_DIR}..."
	make 1> ${LOGS_DIR}/unix_odbc_make.log 2> ${LOGS_DIR}/unix_odbc_make.err
	sudo make install 1> ${LOGS_DIR}/unix_odbc_install.log 2> ${LOGS_DIR}/unix_odbc_install.err
	echo "unixODBC 2.3.9 successfully installed."
	echo "See log output under ${LOGS_DIR} for details"
	echo ""
}

function install_gperf() {
	cd ${LIBS_DIR}
	echo "Extracting ${RSRC_DIR}/gperf-3.1.tar.gz under ${LIBS_DIR}..."
        tar -xzf ${RSRC_DIR}/gperf-3.1.tar.gz
        cd gperf-3.1
        echo "Begin configuring gperf-3.1..."
        ./configure CFLAGS=-m32 --prefix=${GPERF_DIR} 1> ${LOGS_DIR}/gperf_config.log 2> ${LOGS_DIR}/gperf_config.err
        echo "Configuartion complete"
        echo "Building and installing gperf-3.1 under ${GPERF_DIR}..."
        make 1> ${LOGS_DIR}/gperf_make.log 2> ${LOGS_DIR}/gperf_make.err
        sudo make install 1> ${LOGS_DIR}/gperf_install.log 2> ${LOGS_DIR}/gperf_install.err
        echo "gperf-3.1 successfully installed."
        echo "See log output under ${LOGS_DIR} for details"
	echo ""
}

function install_freetds() {
	cd ${LIBS_DIR}
        echo "Extracting ${RSRC_DIR}/freetds.tar.gz under ${LIBS_DIR}..."
        tar -xzf ${RSRC_DIR}/freetds.tar.gz
        cd freetds
        echo "Begin configuring freetds-7.4..."
        ./configure CFLAGS=-m32 --prefix=${FREETDS_DIR} --with-tdsver=7.4.1 --with-unixodbc=${ODBC_DIR} --disable-apps --enable-msdblib --enable-sybase-compat 1> ${LOGS_DIR}/gperf_config.log 2> ${LOGS_DIR}/gperf_config.err
        echo "Configuartion complete"
        echo "Building and installing freetds-7.4 under ${FREETDS_DIR}..."
        make 1> ${LOGS_DIR}/freetds_make.log 2> ${LOGS_DIR}/freetds_make.err
        sudo make install 1> ${LOGS_DIR}/freetds_install.log 2> ${LOGS_DIR}/freetds_install.err
        echo "freetds-7.4 successfully installed."
        echo "See log output under ${LOGS_DIR} for details"
	echo ""
}

run_install
