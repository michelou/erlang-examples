# <span id="top">Erlang Examples</span> <span style="font-size:90%;">[⬆](../README.md#top)</span>

<table style="font-family:Helvetica,Arial;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:25%;"><a href="https://erlang.org/" rel="external"><img src="../docs/images/erlang-logo.svg" width="100" alt="Erlang project"/></a></td>
  <td style="border:0;padding:0;vertical-align:text-top;">Directory <a href="."><strong><code>examples\</code></strong></a> contains <a href="https://isocpp.org/" rel="external" title="Erlang">Erlang</a> code examples coming from various websites - mostly from the <a href="https://erlang.org/" rel="external" title="Erlang">Erlang</a> project.<br/>
  It also includes build scripts (<a href="https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_02_01.html" rel="external">bash scripts</a>, <a href="https://en.wikibooks.org/wiki/Windows_Batch_Scripting" rel="external">batch files</a>, <a href="https://makefiletutorial.com/" rel="external">Make scripts</a>) for experimenting with <a href="https://erlang.org/" rel="external">Erlang</a> on a Windows machine.
  </td>
  </tr>
</table>

## <span id="factorial">`factorial` Example</span>

This example has the following directory structure :

<pre style="font-size:80%;">
<b>&gt; <a href="">tree</a> /a /f . | <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr" rel="external">findstr</a> /v /b [A-Z]</b>
|   <a href="./factorial/00download.txt">00download.txt</a>
|   <a href="./factorial/build.bat">build.bat</a>
|   <a href="./factorial/build.sh">build.sh</a>
|   <a href="./factorial/Makefile">Makefile</a>
\---<b>src</b>
    \---<b>main</b>
        \---<b>erlang</b>
                <a href="./factorial/src/main/erlang/factorial.erl">factorial.erl</a>
</pre>

Command [**`build.bat`**](./factorail/build.bat) generates and executes the Erlang program `factorial.beam` :

<pre style="font-size:80%;">
<b>&gt; <a href="./factorial/build.bat">build</a> -verbose run</b>
Compile 1 Erlang source file into directory "target"
Execute Erlang program "target\factorial.beam"
fac1(10) = 120
fac2(10) = 120
fac3(10) = 120
</pre>

<!--=======================================================================-->

## <span id="hello">`hello` Example</span> [**&#x25B4;**](#top)

This example has the following directory structure :

<pre style="font-size:80%;">
<b>&gt; <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/tree" rel="external">tree</a> /a /f . | <a href="https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/findstr" rel="external">findstr</a> /v /b [A-Z]</b>
|   <a href="./hello/build.bat">build.bat</a>
|   <a href="./hello/build.sh">build.sh</a>
|   <a href="./hello/Makefile">Makefile</a>
\---<b>src</b>
    \---<b>main</b>
        \---<b>erlang</b>
                <a href="./hello/src/main/erlang/hello.erl">hello.erl</a>
</pre>

Command [**`build.sh`**](./hello/build.sh) generates and executes the Erlang program `hello.beam` :
<pre style="font-size:80%;">
<b>&gt; <a href="https://man7.org/linux/man-pages/man1/sh.1p.html" rel="external">sh</a> ./<a href="./hello/build.sh">build.sh</a> -verbose clean run</b>
Compile 1 Erlang source file to directory "target"
Execute Erlang program "target\hello.beam"
Hello, World!
</pre>


***

*[mics](https://lampwww.epfl.ch/~michelou/)/October 2024* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[cmd_cli]: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cmd
[make_cli]: https://www.gnu.org/software/make/manual/html_node/Running.html
[sh_cli]: https://man7.org/linux/man-pages/man1/sh.1p.html
