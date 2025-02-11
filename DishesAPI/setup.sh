# I NEED TO ADD MORE NOTES TO THE START OF THIS TO
# RECORD HOW dotnet WAS INITIALLY SET UP.

1. used dotnet-new.sh:
   $ ./dotnet-new.sh DishesAPI

2. cd DishesAPI
3. Install needed framework library packages:
     dotnet add . package 'Microsoft.EntityFrameworkCore.Sqlite'
     dotnet add . package 'Microsoft.EntityFrameworkCore.Tools'
4. Install the EF tools:
     dotnet tool install --global dotnet-ef
5. Add the "ConnectionStrings" element to the appsettings.json
6. Add the "registration call" to the Program.cs file
   (which will cause certain things to be set up when an instance of 
   the Program class is created, which makes things interrogable by 
   the "dotnet ef" tools!)
7. At this point, the following should run without error:
     dotnet ef migrations add InitialMigration
8. After this, the instructor added some code to the 
   Program.cs to force the application to "delete-and-repopulate"
   the application database at each run, for development-and-instruction
   purposes.
   (This was the code which creates a "scope" and then a 
   "context-within-that-scope" in order to send EnsureDeleted()
   and then Migrate() to the scope's ".Database"...)

   This code came immediately before the Run() message is sent
   to the app...


# I think it was set up by simply using aptitude to install 
# the dotnet package, and then we ran various package 
# installations into the local project in order to 
# do what was shown below.  So, for training purposes,
# there is not that much to do?

# These were done through the VS 2022 gui in the course:
dotnet add . package 'Microsoft.EntityFrameworkCore.Sqlite'
dotnet add . package 'Microsoft.EntityFrameworkCore.Tools'

# IMPORTANT:
# CRUCIAL CLI INSTRUCTIONS FROM MICROSOFT:
# https://learn.microsoft.com/en-us/ef/core/cli/dotnet

# Also, in order to do the same things that the instructor did
# from the Visual Studio Package Manager Console,
# you have to install a pile of dotnet-ef tools
# ("Dotnet Entity Framework tools")
dotnet tool install --global dotnet-ef
# OR: 
#   dotnet tool install dotnet-ef
# seemed to be offered as an option, but it wouldn't work on my setup.
#
# You have to create the local manifest file first, in order to do
# a "local tool setup":
#   dotnet new tool-manifest 
# This generates a ".config/dotnet-tools.json" file.

# "Before you can use the tools on a specific project, 
# you'll need to add the Microsoft.EntityFrameworkCore.Design package to it."
dotnet add package Microsoft.EntityFrameworkCore.Design



# Had thought the next thing to do was run
dotnet ef migrations add InitialMigration
# but it output:
    Build started...
    Build succeeded.
    Unable to create a 'DbContext' of type 'RuntimeType'. \
      The exception 'Unable to resolve service for type 'Microsoft.EntityFrameworkCore.DbContextOptions`1[DishesAPI.DbContexts.DishesDbContext]' \
      while attempting to activate 'DishesAPI.DbContexts.DishesDbContext'.' was thrown while attempting to create an instance. \
      For the different patterns supported at design time, see https://go.microsoft.com/fwlink/?linkid=851729

# Have so far tried lots of code changes, but this still 
# doesn't work properly.  So I'm stuck until there is an
# answer or resolution to this problem.

Preceding it with 
  dotnet build
did not help, either.

$ dotnet ef migrations add InitialMigration --project . --startup-project DishesAPI.csproj --msbuildprojectextensionspath obj
Build started...
Build succeeded.
Unable to create a 'DbContext' of type 'RuntimeType'. The exception 'Unable to resolve service for type 'Microsoft.EntityFrameworkCore.DbContextOptions`1[DishesAPI.DbContexts.DishesDbContext]' while attempting to activate 'DishesAPI.DbContexts.DishesDbContext'.' was thrown while attempting to create an instance. For the different patterns supported at design time, see https://go.microsoft.com/fwlink/?linkid=851728 

Trying to specify the "context class" didn't work either:
rstewar@IMLADRIS:~/node-work/dotnet-related/BuildingAspNetCoreMinimalApis/DishesAPI
$ dotnet ef migrations add InitialMigration --context DishesAPI.DbContexts.DishesDbContext --project . --startup-project DishesAPI.csproj --msbuildprojectextensionspath ./obj
Build started...
Build succeeded.
Unable to create a 'DbContext' of type 'DishesAPI.DbContexts.DishesDbContext'. The exception 'Unable to resolve service for type 'Microsoft.EntityFrameworkCore.DbContextOptions`1[DishesAPI.DbContexts.DishesDbContext]' while attempting to activate 'DishesAPI.DbContexts.DishesDbContext'.' was thrown while attempting to create an instance. For the different patterns supported at design time, see https://go.microsoft.com/fwlink/?linkid=851728


# [2025-02-08 Sat 23:07] Trying to push on the rope some more:
#
# I saw, MUCH, MUCH, LATER, from Microsoft's own documentation, that maybe I 
# need to add in the Entity Framework Tasks packages ALSO?  Maybe this 
# is "infrastructure" which needs to freaking "be there," or else
# nothing else works quite right?
dotnet add package Microsoft.EntityFrameworkCore.Tasks

# So, after all that hassle, I also have:
$ dotnet list DishesAPI.sln package
Project 'DishesAPI' has the following package references
   [net8.0]:
   Top-level Package                           Requested   Resolved
   > Microsoft.EntityFrameworkCore.Design      9.0.1       9.0.1
   > Microsoft.EntityFrameworkCore.Sqlite      9.0.1       9.0.1
   > Microsoft.EntityFrameworkCore.Tasks       9.0.1       9.0.1
   > Microsoft.EntityFrameworkCore.Tools       9.0.1       9.0.1

# BUT AH!  IT'S REALLY INTENDED TO HELP WITH THE USE OF MSBUILD, SO 
# IT DOES NOT ACTUALLY APPLY TO THIS SITUATION?

# JUST TRYING TO GET A VERY SIMPLE INITIAL MIGRATION SPECIFIED!

# It turns out that I needed to specify the DbContext class 
# a particular way, with a no-arg constructor!

# Also, the important difference between the instructor's code
# and what actually worked was:
#   the DbContext-class needed to have an override of 
#   the OnConfiguring method?

# Also, I had failed to correctly add an entry to the appsettings.json,
# and a "registration call" to the Program class, defined in Program.cs?
# 

# Also, i later installed dotnet-ildasm:
#   dotnet tool install -g dotnet-ildasm
# BUT:  dotnet-ildasm does NOT work with dotnet core 8;
# it whines that it needs a much-older, not-supported dotnet core v3,
# or some such, so I shall not pursue this further.

# what works better:
dotnet tool install --global ilspycmd 

# and then you can "ilspycmd" on the assemblies generated by the compiler;
# and get confiration that the Program.cs is a short-cut version of
# a more verbosely-defined Program-class file that is generated automatically
# by more compiler boilerplating/templating stuff for dotnet minimal api's etc...


# ************************************************************
# branch:  core-concepts
# altered some basics, and also figured out how to run 
# the https-enabled version from the command line:
dotnet run --launch-profile https

# The following runs the application without executing the 
# build process first, but during development, it's 
# simpler to do the rebuild because the application code
# gets changed and then the application server is re-launched:
dotnet run --launch-profile https --no-build

# [2025-02-11 Tue 13:58]
# A new, significant development:  the use of the AutoMapper
# "tool":
dotnet add . package 'AutoMapper'

# Here's an example run:
$ dotnet add . package 'AutoMapper'
  Determining projects to restore...
  Writing /tmp/tmpxGEHU2.tmp
info : X.509 certificate chain validation will use the fallback certificate bundle at '/usr/share/dotnet/sdk/8.0.403/trustedroots/codesignctl.pem'.
info : X.509 certificate chain validation will use the fallback certificate bundle at '/usr/share/dotnet/sdk/8.0.403/trustedroots/timestampctl.pem'.
info : Adding PackageReference for package 'AutoMapper' into project '/home/rstewar/node-work/dotnet-related/BuildingAspNetCoreMinimalApis/DishesAPI/DishesAPI.csproj'.
info :   GET https://api.nuget.org/v3/registration5-gz-semver2/automapper/index.json
info :   OK https://api.nuget.org/v3/registration5-gz-semver2/automapper/index.json 90ms
info :   GET https://api.nuget.org/v3/registration5-gz-semver2/automapper/page/1.1.0.118/3.1.0-ci1033.json
info :   OK https://api.nuget.org/v3/registration5-gz-semver2/automapper/page/1.1.0.118/3.1.0-ci1033.json 85ms
info :   GET https://api.nuget.org/v3/registration5-gz-semver2/automapper/page/3.1.0-ci1034/3.3.0-ci1002.json
info :   OK https://api.nuget.org/v3/registration5-gz-semver2/automapper/page/3.1.0-ci1034/3.3.0-ci1002.json 81ms
info :   GET https://api.nuget.org/v3/registration5-gz-semver2/automapper/page/3.3.0-ci1003/4.2.1.json
info :   OK https://api.nuget.org/v3/registration5-gz-semver2/automapper/page/3.3.0-ci1003/4.2.1.json 94ms
info :   GET https://api.nuget.org/v3/registration5-gz-semver2/automapper/page/5.0.0-beta-1/13.0.1.json
info :   OK https://api.nuget.org/v3/registration5-gz-semver2/automapper/page/5.0.0-beta-1/13.0.1.json 105ms
info : Restoring packages for /home/rstewar/node-work/dotnet-related/BuildingAspNetCoreMinimalApis/DishesAPI/DishesAPI.csproj...
info :   GET https://api.nuget.org/v3/vulnerabilities/index.json
info :   OK https://api.nuget.org/v3/vulnerabilities/index.json 168ms
info :   GET https://api.nuget.org/v3-vulnerabilities/2025.02.11.04.21.55/vulnerability.base.json
info :   GET https://api.nuget.org/v3-vulnerabilities/2025.02.11.04.21.55/2025.02.11.10.21.56/vulnerability.update.json
info :   OK https://api.nuget.org/v3-vulnerabilities/2025.02.11.04.21.55/vulnerability.base.json 79ms
info :   OK https://api.nuget.org/v3-vulnerabilities/2025.02.11.04.21.55/2025.02.11.10.21.56/vulnerability.update.json 114ms
info : Package 'AutoMapper' is compatible with all the specified frameworks in project '/home/rstewar/node-work/dotnet-related/BuildingAspNetCoreMinimalApis/DishesAPI/DishesAPI.csproj'.
info : PackageReference for package 'AutoMapper' version '13.0.1' added to file '/home/rstewar/node-work/dotnet-related/BuildingAspNetCoreMinimalApis/DishesAPI/DishesAPI.csproj'.
info : Writing assets file to disk. Path: /home/rstewar/node-work/dotnet-related/BuildingAspNetCoreMinimalApis/DishesAPI/obj/project.assets.json
log  : Restored /home/rstewar/node-work/dotnet-related/BuildingAspNetCoreMinimalApis/DishesAPI/DishesAPI.csproj (in 390 ms).

# So, here's the list of installed packages now:
$ dotnet list . package
Project 'DishesAPI' has the following package references
   [net8.0]:
   Top-level Package                           Requested   Resolved
   > AutoMapper                                13.0.1      13.0.1
   > Microsoft.EntityFrameworkCore.Design      9.0.1       9.0.1
   > Microsoft.EntityFrameworkCore.Sqlite      9.0.1       9.0.1
   > Microsoft.EntityFrameworkCore.Tasks       9.0.1       9.0.1
   > Microsoft.EntityFrameworkCore.Tools       9.0.1       9.0.1

# ##########################################################


