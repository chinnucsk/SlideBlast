# SlideBlast.com

## What is SlideBlast?

SlideBlast is a realtime, web-based presentation tool built using
Erlang, <a href="http://nitrogenproject.com">Nitrogen</a> and <a
href="http://riak.basho.com">Riak</a>. It lets you display slides to
multiple people through the web, and ensures that all attendees are
viewing the same slide.

## Installation

### Step 1: Download and Install Ghostscript and Imagemagick

* Ghostscript - <a href="http://pages.cs.wisc.edu/~ghost/">Link</a>
* Imagemagick - <a href="http://www.imagemagick.org/script/download.php">Link</a>

### Step 2: Download, Install, and run Riak 0.9.1

* [Download Riak 0.10.1](http://downloads.basho.com/riak/riak-0.10.1/)
* [Install Instructions](http://wiki.basho.com/display/RIAK/Getting+Started)

### Step 3: Download and Build Nitrogen

You can download a self-contained Nitrogen install for your platform
from here:
[Nitrogen Downloads](http://nitrogenproject.com/downloads). Unzipping
the .tar.gz, will create a 'nitrogen' directory.

Alternatively, build from source:
      
    git clone git://github.com/rklophaus/nitrogen.git
    cd nitrogen
    make rel_inets
    cd rel/nitrogen

### Step 4: Get Dependencies

Change to the rel/nitrogen/lib directory, then run:

    hg clone http://bitbucket.org/basho/protobuffs
    make -C protobuffs
    hg clone http://bitbucket.org/basho/riak-erlang-client
    make -C riak-erlang-client

### Step 5: Download and Configure the SlideBlast.com, and Start the Server

The default project contains skeleton code that we don't need. Delete the skeleton code:

    rm -rf site
    
Now, pull the latest SlideBlast code from GitHub:

    git clone git://github.com/rklophaus/SlideBlast.git site
    
Set the Riak connection info in *etc/app.config*. Add these lines at the bottom of the 'nitrogen' configuration section:

    % Specify the riak node.
    {riak_ip, "127.0.0.1"},
    {riak_port, 8087}
    
Compile and start:
        
    make
    bin/nitrogen console

Browse to [http://localhost:8000]	
	
Enjoy!
