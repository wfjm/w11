# Installl from legacy OpenCores svn repository

The w11 project started on 
[OpenCores](http://opencores.org) as project
[w11](http://opencores.org/project,w11).

In October 2016 the repository was [moved from OpenCores to GitHub](https://wfjm.github.io/blogs/w11/2016-12-11-w11-moved-to-github.html). 
The full revision history was kept and can be accessed from
[GitHub wfjm/w11](https://github.com/wfjm/w11).

The OpenCores svn repository remains available and can also be used to
retrieve old revisions:

- to download tagged verions (from major releases) list available svn tags
      
        svn ls http://opencores.org/ocsvn/w11/w11/tags

   and download one of them

        cd <install-dir>
        svn co http://opencores.org/ocsvn/w11/w11/tags/<tag>

- to download specific svn revision (from minor releases) determine desired 
  svn revsion from list given on http://opencores.org/project,w11,overview
  and download 

        cd <install-dir>
        svn co -r <rev> http://opencores.org/ocsvn/w11/w11/trunk
