# I think Kevin Dockx specified a name of "DishesAPI"
#
dotnet new webapi \
  -n ${1} \
  --auth None \
  --no-openapi
