FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["MyStagePass.Subscriber/MyStagePass.Subscriber.csproj", "MyStagePass.Subscriber/"]
COPY ["MyStagePass.Model/MyStagePass.Model.csproj", "MyStagePass.Model/"]
COPY ["MyStagePass.Services/MyStagePass.Services.csproj", "MyStagePass.Services/"]
RUN dotnet restore "MyStagePass.Subscriber/MyStagePass.Subscriber.csproj"
COPY . .
WORKDIR "/src/MyStagePass.Subscriber"
RUN dotnet build "MyStagePass.Subscriber.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "MyStagePass.Subscriber.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MyStagePass.Subscriber.dll"]