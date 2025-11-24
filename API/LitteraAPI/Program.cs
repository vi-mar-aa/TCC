using System.Text.Json.Serialization;
using LitteraAPI.DTOS;
using LitteraAPI.Repositories;
using LitteraAPI.Routes;

var builder = WebApplication.CreateBuilder(args);


builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();


builder.Services.AddCors(options =>
{
    options.AddPolicy("PermitirTudo", policy =>
    {
        policy
            .AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

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
builder.Services.AddScoped<RepoIndicacao>();
builder.Services.AddScoped<RepoDenuncia>();



var connectionString = builder.Configuration.GetConnectionString("SqlServer");
builder.Services.Configure<Microsoft.AspNetCore.Http.Json.JsonOptions>(options =>
{
    options.SerializerOptions.Converters.Add(new JsonStringEnumConverter());
});

builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.Converters.Add(new JsonStringEnumConverter());
});

var app = builder.Build();


if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}


app.UseCors("PermitirTudo");

app.UseHttpsRedirection();

app.UseAuthorization();


app.Routescliente();
app.Routesfuncionario();
app.Routesmidia();
app.Routesreserva();
app.RoutesLista();
app.Routesemprestimo();
app.RoutesEvento();
app.Routesparametros();
app.RoutesMensagem();
app.RoutesIndicacao();
app.RoutesDenuncia();


app.Run();