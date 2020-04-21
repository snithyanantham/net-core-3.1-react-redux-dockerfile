FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base
RUN apt-get update -yq \
    && apt-get install curl gnupg -yq \
    && curl -sL https://deb.nodesource.com/setup_13.x | bash \
    && apt-get install nodejs -yq
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build

RUN apt-get update -yq \
    && apt-get install curl gnupg -yq \
    && curl -sL https://deb.nodesource.com/setup_13.x | bash \
    && apt-get install nodejs -yq

WORKDIR /src
COPY ["SampleApplication/SampleApplication.csproj", "SampleApplication/"]
RUN dotnet restore "SampleApplication.csproj"
COPY . .
WORKDIR "/src"

RUN dotnet build "SampleApplication.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "SampleApplication.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SampleApplication.dll"]
