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
var connectionString = builder.Configuration.GetConnectionString("SqlServer");
var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
//Falta procedures nas midias separar as procs
// Main android
// Parametros
app.UseHttpsRedirection();
app.Routescliente();
app.Routesfuncionario();
app.Routesmidia();
app.Routesreserva();
app.RoutesLista();
app.Routesemprestimo();
app.Run();

