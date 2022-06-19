#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["OpenApiDockerSample.csproj", "."]
RUN dotnet restore "./OpenApiDockerSample.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "OpenApiDockerSample.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "OpenApiDockerSample.csproj" -c Release -o /app/publish

FROM publish AS exportswagger
WORKDIR /app
RUN dotnet tool install --version 6.3.1 Swashbuckle.AspNetCore.Cli --tool-path /dotnet-global-tools
LABEL swagger=true
RUN /dotnet-global-tools/swagger tofile --output swagger.json publish/OpenApiDockerSample.dll v1

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "OpenApiDockerSample.dll"]