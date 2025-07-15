# Use the official .NET 9.0 runtime as base image
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Use the official .NET 9.0 SDK for building
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Copy package management files
COPY ["Directory.Packages.props", "./"]
COPY ["nuget.config", "./"]
COPY ["Directory.Build.props", "./"]
COPY ["Directory.Build.targets", "./"]

# Copy project files and restore dependencies
COPY ["src/WebhookClient/WebhookClient.csproj", "WebhookClient/"]
COPY ["src/eShop.ServiceDefaults/eShop.ServiceDefaults.csproj", "eShop.ServiceDefaults/"]

RUN dotnet restore "WebhookClient/WebhookClient.csproj"

# Copy source code
COPY src/ .
WORKDIR "/src/WebhookClient"

# Build the application
RUN dotnet build "WebhookClient.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Publish the application
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "WebhookClient.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Final stage
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "WebhookClient.dll"]
