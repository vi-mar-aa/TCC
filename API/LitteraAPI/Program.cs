using System.Text.Json.Serialization;
using LitteraAPI.DTOS;
using LitteraAPI.Repositories;
using LitteraAPI.Routes;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();

builder.Services.AddSwaggerGen();
builder.Services.AddScoped<RepoCliente>();
builder.Services.AddScoped<RepoFuncionario>();
builder.Services.AddScoped<RepoMidia>();
builder.Services.AddScoped<RequestMidia>();
builder.Services.AddScoped<RepoReserva>();
builder.Services.AddScoped<RepoLista>();
builder.Services.AddScoped<RepoEmprestimo>();
builder.Services.AddScoped<RepoEvento>();
builder.Services.AddScoped<RepoParametros>();
builder.Services.AddScoped<RepoMensagem>();
var connectionString = builder.Configuration.GetConnectionString("SqlServer");
builder.Services.Configure<Microsoft.AspNetCore.Http.Json.JsonOptions>(options =>
{
    options.SerializerOptions.Converters.Add(new JsonStringEnumConverter());
});

var app = builder.Build();



// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// eventos
// o inativar midia, não possibilita inativar apenas um exemplar
// questão da disponiblidade, gen e tipagem

app.UseHttpsRedirection();
app.Routescliente();
app.Routesfuncionario();
app.Routesmidia();
app.Routesreserva();
app.RoutesLista();
app.Routesemprestimo();
app.RoutesEvento();
app.Routesparametros();
app.RoutesMensagem();
app.Run();

