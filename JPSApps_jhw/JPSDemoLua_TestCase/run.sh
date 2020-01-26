export LD_LIBRARY_PATH=../libs/
chmod +x JPSDemoLua_TestCase*
./JPSDemoLua_TestCase*
#valgrind --leak-check=yes --num-callers=10 --time-stamp=yes --track-origins=yes --log-file=./vlgrnd.log ./JPSDemoLua_TestCase*
