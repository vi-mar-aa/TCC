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
var connectionString = builder.Configuration.GetConnectionString("SqlServer");
var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
//Falta procedures nas midias
//Fazer as coisas do acervo
// android
app.UseHttpsRedirection();
app.Routescliente();
app.Routesfuncionario();
app.Routesmidia();
app.Run();

