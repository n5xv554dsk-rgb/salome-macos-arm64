.. _python_console_page: 

******************
Python Console
******************

**Python console** - Window for Python interpreter. This window functions like a standard document:
the pop-up menu invoked by right-click in this window gives access to **Copy/Paste/SelectAll/ClearAll** options.

You can run a Python script in interactive mode by typing expressions line by line or by loading a Python file
from the main menu **File -> Load Script**.

==================
Asynchronous mode
==================

By default the console is always initialized in synchronous mode. It means that each Python command is executed in the main GUI thread,
then GUI is blocked until the command is finished. It was done this way to prevent crashes of PARAVIS scripts,
when VTK does not run in the main thread.

However, it could be an issue if you run a time consuming Python script, because you won't see any output till the end of the execution.

In this case you can switch on the asynchronous mode, when the Python commands are executed in the separated thread,
that doesn't block the main GUI loop. So, you'll see any intermediate output from the running script even if the script didn't finish yet.

To switch asynchronous mode on, set ``PYTHON_CONSOLE_SYNC`` environment variable to any value less or equal to 0 before Salome start:

.. code-block:: console

    export PYTHON_CONSOLE_SYNC=0

To return back to synchronous mode, set ``PYTHON_CONSOLE_SYNC`` to any value greater than 0. Currently undefined ``PYTHON_CONSOLE_SYNC``
switches to sync mode as well for compatibility reasons.

==================
Tracing
==================

To output in console currently executed functions, we're adding tracing code to the start and at the end
of the command to deactivate it immediately after execution.

This mechanism is turned off by default. Set ``PYCONSOLE_TRACE`` before SALOME start to activate it:

.. code-block:: console

    export PYCONSOLE_TRACE=1

If the tracing is on while the script is running we can see functions enter and return calls
with ``>>`` and ``<<`` marks followed by line number and function name. Tracing function prints only calls to functions
defined in the current script to prevent printing of thousands of lines for builtin functions in some cases.

Example of a script with defined functions:

.. code-block:: python
    :linenos:

    #!/usr/bin/env python

    import time

    def sum(x, y):
        time.sleep(3)
        return x + y
        
    def sub(x, y):
        time.sleep(3)
        return x - y
        
    def prod(x, y):
        time.sleep(3)
        return x * y
        
    def div(x, y):
        time.sleep(3)
        return x / y

    x = 5
    y = 2

    sum(x, y)
    sub(x, y)
    prod(x, y)
    div(x, y)

And output in the Python console:

.. code-block:: console

    >>> sys.setprofile(lambda frame, event, arg: print('>>', frame.f_lineno, ': ', frame.f_code.co_name) if event == 'call' and frame.f_code.co_filename == '/home/function_calls.py' and frame.f_code.co_name != '<module>' else print('<<', frame.f_lineno, ': ', frame.f_code.co_name) if event == 'return' and frame.f_code.co_filename == '/home/function_calls.py' and frame.f_code.co_name != '<module>' else None); exec(compile(open('/home/function_calls.py', 'rb').read(), '/home/function_calls.py', 'exec')); sys.setprofile(None); 
    >> 5 :  sum
    << 7 :  sum
    >> 9 :  sub
    << 11 :  sub
    >> 13 :  prod
    << 15 :  prod
    >> 17 :  div
    << 19 :  div
    >>>

