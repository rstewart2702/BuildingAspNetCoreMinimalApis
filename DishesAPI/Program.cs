using AutoMapper;
using DishesAPI.DbContexts;
using DishesAPI.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MinimalAPIDemo.Models;

// THIS SOURCE FILE MUST RESULT IN A TOP-LEVEL, "MAIN" CLASS
// WHICH CONFORMS TO SOME PRE-DETERMINED EXPECTATION,
// WHICH MAKES IT POSSIBLE FOR THINGS LIKE THE EF-CORE
// MIGRATIONS TO FIND WHAT IT NEEDS TO GENERATE 
// DATABASE STRUCTURE-MIGRATIONS PROGRAMS BY EXAMINING 
// COMPILED ASSEMBLIES?

// Hmmm:  so, this is actually going to result in something like
//        a pre-defined args (and precisely where it is defined is a present mystery...)
//        and yet this results in something which the enclosing system can interrogate
//        and process.
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

// register the DbContext on the container, getting the
// connection string from appSettings
builder.Services.AddDbContext<DishesDbContext>(
    o => o.UseSqlite(builder.Configuration["ConnectionStrings:DishesDBConnectionString"])
);

// This corresponds to the addition of the AutoMapper packages to 
// our project.  
// The 
//   AppDomain.CurrentDomain.GetAssemblies()
// expression retrieves all of the "currently loaded assemblies," so that 
// the profiles-of-mapping-configurations (for mappings from Entity-classes
// to DTO-classes, and back again) can be found by the "AutoMapper library/system."
//
builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());

var app = builder.Build();

// Configure the HTTP request pipeline.

app.UseHttpsRedirection();

var summaries = new[]
{
    "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
};

// ROUTES:
// There are several kinds of routes the instructor started to discuss.
app.MapGet(
    "/dishes", 
    async (
        DishesDbContext context, 
        IMapper mapper,
        [FromQuery] string? name // his stupid program example didn't let me  
    ) =>
    {
        return mapper.Map<IEnumerable<DishDto>>(
            await context.Dishes
            .Where(d => name == null || d.Name.Contains(name))
            .ToListAsync()
            );
    })  ;

// Included are routes for which "arguments" or parameters are specified:
//   N.B. Now, we've injected an IMapper instance 
//   and we use it to map from a Dish instance to a DishDto instance
//   according to what's retrieved from the database and transformed
//   into an instance of Dish.
app.MapGet(
    "/dishes/{dishId:guid}",
    async (
        DishesDbContext dishesDbContext,
        IMapper mapper,
        Guid dishId
    ) =>
    {
        return
        mapper.Map<DishDto>(
            await
            dishesDbContext.
            Dishes.
            FirstOrDefaultAsync(
                d => d.Id == dishId
            )
        )
        ;
    }
);

// In the initial exercise, this exposed an issue with the data model,
// in that the JSON libraries detected an object-graph cycle?
app.MapGet(
    "/dishes/{dishId}/ingredients",
    async (DishesDbContext dishesDbContext, IMapper mapper, Guid dishId) =>
    {
        return mapper.Map<IEnumerable<IngredientDto>>(
            (
                await 
                dishesDbContext.Dishes
                .Include(d => d.Ingredients)
                .FirstOrDefaultAsync(
                    d => d.Id == dishId
                )
            )?.Ingredients
        );
    }
);


app.MapGet(
    "/dishes/{dishName:alpha}",
    async (DishesDbContext dishesContext, IMapper mapper, string dishName) =>
    {
        return (
            mapper.Map<DishDto>(
                await
                dishesContext.Dishes
                // .Include(d => d.Name)
                .FirstOrDefaultAsync(
                    d => d.Name == dishName
                )
            ) // ?.Name;
        );
    }
);

// Added by the instructor at almost the end of the "Demo:  Adding the Data Layer" 
// lesson:
// "recreate & migrate the database on each run, for demo purposes"
using (var serviceScope = app.Services.GetService<IServiceScopeFactory>().CreateScope()) {
    var context = serviceScope.ServiceProvider.GetRequiredService<DishesDbContext>();
    context.Database.EnsureDeleted();
    context.Database.Migrate();
}

app.Run();

