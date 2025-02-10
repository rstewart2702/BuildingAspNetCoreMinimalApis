# I NEED TO ADD MORE NOTES TO THE START OF THIS TO
# RECORD HOW dotnet WAS INITIALLY SET UP.

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
