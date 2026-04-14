//
//  ContentView.swift
//  Sora Escape
//
//  Created by Emir Dalkılıç on 6.04.2026.
//

import SwiftUI
import UIKit

enum AppPhase {
    case splash
    case menu
    case game
}

struct Obstacle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var usesPinkPalette: Bool
    var hasScored: Bool = false
}

struct ContentView: View {
    @State private var phase: AppPhase = .splash

    @State private var playerX: CGFloat = 200
    @State private var score: Int = 0
    @State private var highScore: Int = 0
    @State private var obstacles: [Obstacle] = []
    @State private var gameTimer: Timer?
    @State private var obstacleSpawnCounter: Int = 0
    @State private var isGameOver: Bool = false
    @State private var isPaused: Bool = false

    @State private var currentFallSpeed: CGFloat = 6
    @State private var currentSpawnInterval: Int = 25
    @State private var screenShakeOffset: CGFloat = 0

    @State private var splashTopCover: CGFloat = 0
    @State private var splashBottomCover: CGFloat = 0
    @State private var splashLogoOpacity: CGFloat = 0
    @State private var splashTextOpacity: CGFloat = 0
    @State private var splashScale: CGFloat = 0.92
    @State private var splashOpacity: CGFloat = 1
    @State private var menuCharacterOffset: CGFloat = 180
    @State private var menuCharacterOpacity: CGFloat = 0
    @State private var menuNeonPhase: Bool = false

    private let playerWidth: CGFloat = 82
    private let playerHeight: CGFloat = 82

    // görsel aynı olsa dda hitboxı daha küçük ve daha iyi hissiyat sağlıyor.
    private let playerHitboxWidth: CGFloat = 50
    private let playerHitboxHeight: CGFloat = 56

    private let baseFallSpeed: CGFloat = 6
    private let baseSpawnInterval: Int = 25
    private let minimumSpawnInterval: Int = 10

    
    private let playerBottomOffset: CGFloat = 72

    var body: some View {
        ZStack {
            switch phase {
            case .splash:
                splashView

            case .menu:
                menuView

            case .game:
                gameView
            }
        }
    }

    // MARK: - Splash

    private var splashView: some View {
        GeometryReader { geo in
            ZStack {
                Color.white
                    .ignoresSafeArea()

                VStack(spacing: 14) {
                    Image("arvis")
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(220, geo.size.width * 0.48))
                        .opacity(splashLogoOpacity)
                        .scaleEffect(splashScale)
                        .shadow(color: .white.opacity(0.02), radius: 12)

                    Text("internship")
                        .textCase(.uppercase)
                        .font(.headline)
                        .foregroundColor(.black.opacity(0.92))
                        .opacity(splashTextOpacity)

                    Text("INTERN: Emir Dalkılıç")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.72))
                        .opacity(splashTextOpacity)
                }

                VStack(spacing: 0) {
                    Color.black
                        .frame(height: splashTopCover)

                    Spacer()

                    Color.black
                        .frame(height: splashBottomCover)
                }
                .ignoresSafeArea()
            }
            .opacity(splashOpacity)
            .onAppear {
                runSplashSequence(screenHeight: geo.size.height)
            }
        }
    }

    private func runSplashSequence(screenHeight: CGFloat) {
        splashTopCover = screenHeight / 2
        splashBottomCover = screenHeight / 2
        splashLogoOpacity = 0
        splashTextOpacity = 0
        splashScale = 0.92
        splashOpacity = 1

        withAnimation(.easeOut(duration: 0.55)) {
            splashLogoOpacity = 1
            splashScale = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.65)) {
                splashTopCover = 0
                splashBottomCover = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            withAnimation(.easeOut(duration: 0.45)) {
                splashTextOpacity = 1
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.35) {
            withAnimation(.easeInOut(duration: 0.65)) {
                splashOpacity = 0
                splashScale = 1.03
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                phase = .menu
            }
        }
    }

    // MARK: - Menu

    private var menuView: some View {
        GeometryReader { geo in
            ZStack {
                menuBackgroundView

                VStack(spacing: 18) {
                    VStack(spacing: 18) {
                        Image("arvis")
                            .resizable()
                            .scaledToFit()
                            .frame(width: min(120, geo.size.width * 0.66))
                            .overlay {
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.00, green: 0.42, blue: 0.82).opacity(menuNeonPhase ? 0.26 : 0.10),
                                        Color(red: 0.16, green: 0.95, blue: 0.88).opacity(menuNeonPhase ? 0.30 : 0.12),
                                        Color.white.opacity(menuNeonPhase ? 0.16 : 0.05)
                                    ],
                                    startPoint: menuNeonPhase ? .leading : .topLeading,
                                    endPoint: menuNeonPhase ? .trailing : .bottomTrailing
                                )
                                .blendMode(.screen)
                            }
                            .shadow(
                                color: Color(red: 1.00, green: 0.42, blue: 0.82).opacity(menuNeonPhase ? 0.24 : 0.08),
                                radius: menuNeonPhase ? 18 : 10
                            )
                            .shadow(
                                color: Color(red: 0.16, green: 0.95, blue: 0.88).opacity(menuNeonPhase ? 0.24 : 0.08),
                                radius: menuNeonPhase ? 16 : 8
                            )

                        Text("SORA ESCAPE")
                            .font(.system(size: 34, weight: .black, design: .serif))
                            .italic()
                            .tracking(4)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color.white,
                                        Color(red: 0.97, green: 0.84, blue: 0.88)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay {
                                Text("SORA ESCAPE")
                                    .font(.system(size: 34, weight: .black, design: .serif))
                                    .italic()
                                    .tracking(4)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 1.00, green: 0.42, blue: 0.82),
                                                Color(red: 0.16, green: 0.95, blue: 0.88),
                                                Color(red: 0.42, green: 0.78, blue: 1.00)
                                            ],
                                            startPoint: menuNeonPhase ? .leading : .trailing,
                                            endPoint: menuNeonPhase ? .trailing : .leading
                                        )
                                    )
                                    .blur(radius: 1.2)
                                    .opacity(0.9)
                            }
                            .shadow(color: .black.opacity(0.32), radius: 10, y: 4)
                            .shadow(
                                color: Color(red: 1.00, green: 0.42, blue: 0.82).opacity(menuNeonPhase ? 0.75 : 0.28),
                                radius: menuNeonPhase ? 24 : 12
                            )
                            .shadow(
                                color: Color(red: 0.16, green: 0.95, blue: 0.88).opacity(menuNeonPhase ? 0.82 : 0.34),
                                radius: menuNeonPhase ? 34 : 14
                            )
                            .scaleEffect(menuNeonPhase ? 1.015 : 0.985)
                    }
                    .padding(.top, geo.safeAreaInsets.top - 18)
                    .onAppear {
                        runMenuEntranceAnimation()
                        startMenuNeonAnimation()
                    }

                    Spacer()

                    Button {
                        startNewGame()
                    } label: {
                        Text("Play")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .frame(width: 170, height: 52)
                            .background(
                                LinearGradient(
                                    colors: [
                                        menuNeonPhase
                                            ? Color(red: 1.00, green: 0.34, blue: 0.80)
                                            : Color(red: 0.15, green: 0.88, blue: 0.84),
                                        menuNeonPhase
                                            ? Color(red: 0.20, green: 0.95, blue: 0.90)
                                            : Color(red: 0.62, green: 0.38, blue: 1.00)
                                    ],
                                    startPoint: menuNeonPhase ? .leading : .topLeading,
                                    endPoint: menuNeonPhase ? .trailing : .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(menuNeonPhase ? 0.75 : 0.38), lineWidth: 1.2)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(
                                color: Color(red: 1.00, green: 0.42, blue: 0.82).opacity(menuNeonPhase ? 0.62 : 0.25),
                                radius: menuNeonPhase ? 22 : 10
                            )
                            .shadow(
                                color: Color(red: 0.16, green: 0.95, blue: 0.88).opacity(menuNeonPhase ? 0.72 : 0.30),
                                radius: menuNeonPhase ? 30 : 12
                            )
                            .scaleEffect(menuNeonPhase ? 1.035 : 0.985)
                    }

                    Spacer()
                        .frame(height: 56)
                }
                .padding()

                Image("mainmenumiku")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        maxWidth: min(geo.size.width * 0.82, 360),
                        maxHeight: min(geo.size.height * 0.38, 320)
                    )
                    .offset(x: menuCharacterOffset)
                    .opacity(menuCharacterOpacity)
                    .shadow(color: .black.opacity(0.20), radius: 18, y: 10)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.57)
            }
        }
    }

    private func runMenuEntranceAnimation() {
        menuCharacterOffset = 220
        menuCharacterOpacity = 0

        withAnimation(.spring(response: 1.2, dampingFraction: 0.86)) {
            menuCharacterOffset = 0
            menuCharacterOpacity = 1
        }
    }

    private func startMenuNeonAnimation() {
        guard menuNeonPhase == false else { return }

        withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
            menuNeonPhase = true
        }
    }

    private var menuBackgroundView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Image("pixelart")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.25),
                    Color.black.opacity(0.10),
                    Color.black.opacity(0.45)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Game

    private var gameView: some View {
        GeometryReader { geo in
            let playerY = geo.size.height - playerBottomOffset

            ZStack {
                backgroundView

                dragControlLayer(geo: geo)

                scoreBoard(geo: geo)

                ForEach(obstacles) { obstacle in
                    obstacleView(obstacle)
                }

                playerTrailView(playerY: playerY)

                playerView
                    .position(x: playerX, y: playerY)
                
                pauseButton(geo: geo)
                
                if isPaused{
                    pausedOverlay()
                }

                if isGameOver {
                    gameOverOverlay(geo: geo)
                }
            }
            .offset(x: screenShakeOffset)
            .contentShape(Rectangle())
            .onAppear {
                playerX = geo.size.width / 2
                startGame(in: geo)
            }
            .onDisappear {
                gameTimer?.invalidate()
            }
        }
    }

    // MARK: - Background

    private var backgroundView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Image("pixelart")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.08),
                    Color(red: 0.22, green: 0.08, blue: 0.18).opacity(0.18),
                    Color.black.opacity(0.30)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                Spacer()

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.pink.opacity(0.06),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 120)
                    .blur(radius: 12)
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - HUD

    private func scoreBoard(geo: GeometryProxy) -> some View {
        VStack(spacing: 6) {
            Text("SORA ESCAPE")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.88))
                .tracking(3)

            Text("Score: \(score)")
                .font(.title)
                .fontWeight(.heavy)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color(red: 1.0, green: 0.72, blue: 0.86)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text("High Score: \(highScore)")
                .foregroundColor(.white.opacity(0.92))
                .font(.subheadline)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.22), radius: 8)
        .position(x: geo.size.width / 2, y: 78)
    }

    // MARK: - Player

    private var playerView: some View {
        Image("player_64x64")
            .resizable()
            .scaledToFit()
            .frame(width: playerWidth, height: playerHeight)
            .shadow(color: .white.opacity(0.18), radius: 8)
    }

    private func playerTrailView(playerY: CGFloat) -> some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.00),
                        Color.white.opacity(0.16),
                        Color.pink.opacity(0.10)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: playerWidth * 0.30, height: playerHeight * 0.82)
            .blur(radius: 8)
            .position(x: playerX, y: playerY + playerHeight * 0.12)
    }

    // MARK: - Obstacles

    private func obstacleView(_ obstacle: Obstacle) -> some View {
        let neonColors = obstacle.usesPinkPalette
            ? [
                Color(red: 1.00, green: 0.74, blue: 0.90),
                Color(red: 1.00, green: 0.40, blue: 0.78),
                Color(red: 1.00, green: 0.18, blue: 0.64)
            ]
            : [
                Color(red: 0.38, green: 1.00, blue: 0.96),
                Color(red: 0.08, green: 0.90, blue: 1.00),
                Color(red: 0.00, green: 0.56, blue: 0.92)
            ]

        let glowColor = obstacle.usesPinkPalette
            ? Color(red: 1.00, green: 0.36, blue: 0.76)
            : Color(red: 0.12, green: 0.94, blue: 1.00)

        return ZStack {
            RoundedRectangle(cornerRadius: obstacle.size * 0.16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: neonColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: obstacle.size, height: obstacle.size)
                .overlay(
                    RoundedRectangle(cornerRadius: obstacle.size * 0.16, style: .continuous)
                        .stroke(Color.white.opacity(0.45), lineWidth: 1.4)
                )
                .shadow(color: glowColor.opacity(0.95), radius: 12)
                .shadow(color: glowColor.opacity(0.55), radius: 24)

            RoundedRectangle(cornerRadius: obstacle.size * 0.10, style: .continuous)
                .fill(Color.white.opacity(0.28))
                .frame(width: obstacle.size * 0.22, height: obstacle.size * 0.58)
                .offset(x: -obstacle.size * 0.18, y: -obstacle.size * 0.06)
        }
        .position(x: obstacle.x, y: obstacle.y)
    }

    // MARK: - Controls

    private func dragControlLayer(geo: GeometryProxy) -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.001))
            .frame(width: geo.size.width, height: geo.size.height)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
            .highPriorityGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard !isGameOver && !isPaused else { return }

                        let half = playerWidth / 2
                        let clampedX = min(max(value.location.x, half), geo.size.width - half)
                        playerX = clampedX
                    }
            )
    }
    
    private func pauseButton(geo: GeometryProxy) -> some View{
        Button {
            guard !isGameOver else { return }
            isPaused.toggle()
            softHaptic()
        } label: {
            Image(systemName: isPaused ? "play.fill": "pause.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.black.opacity(0.35))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.25), radius:8)
        }
                .position(
                    x: geo.size.width - 34,
                    y: max(geo.safeAreaInsets.top + 24, 34)
                )
        
    }

    // MARK: - Game Over

    private func gameOverOverlay(geo: GeometryProxy) -> some View {
        VStack(spacing: 14) {
            Text("GAME OVER")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)

            Text("Final Score: \(score)")
                .foregroundColor(.white.opacity(0.92))
                .font(.title3)

            Text("High Score: \(highScore)")
                .foregroundColor(.white.opacity(0.80))
                .font(.subheadline)

            HStack(spacing: 12) {
                Button("Restart") {
                    restartGame(in: geo)
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [
                            Color.pink.opacity(0.55),
                            Color.purple.opacity(0.40)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button("Menu") {
                    goToMenu()
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.14))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .frame(maxWidth: 260)
        .padding(22)
        .background(Color.black.opacity(0.50))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private func pausedOverlay() -> some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                Text("PAUSED")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Button{
                    isPaused = false
                    softHaptic()
                } label: {
                    Text("Resume")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 140, height: 44)
                        .background(Color.white.opacity(0.14))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )
                }
                
                Button{
                                isPaused = false
                                goToMenu()
                                softHaptic()
                            } label: {
                                Text("Main Menu")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 160, height: 46)
                                    .background(Color.pink.opacity(0.24))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.pink.opacity(0.28), lineWidth: 1)
                                    )
                                    
                            }
            }
            
            
            .padding(.horizontal, 28)
            .padding(.vertical, 20)
            .background(Color.black.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }

    // MARK: - Flow

    private func startNewGame() {
        gameTimer?.invalidate()

        score = 0
        obstacles = []
        obstacleSpawnCounter = 0
        isGameOver = false
        currentFallSpeed = baseFallSpeed
        currentSpawnInterval = baseSpawnInterval
        screenShakeOffset = 0

        withAnimation(.easeInOut(duration: 0.25)) {
            phase = .game
        }
    }

    private func goToMenu() {
        gameTimer?.invalidate()

        withAnimation(.easeInOut(duration: 0.25)) {
            phase = .menu
        }
    }

    // MARK: - Game Logic

    func startGame(in geo: GeometryProxy) {
        gameTimer?.invalidate()

        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            updateObstacles(in: geo)
        }
    }

    func updateObstacles(in geo: GeometryProxy) {
        if isGameOver || isPaused {
            return
        }

        for index in obstacles.indices {
            obstacles[index].y += currentFallSpeed
        }

        obstacleSpawnCounter += 1

        if obstacleSpawnCounter >= currentSpawnInterval {
            spawnObstacle(in: geo)
            obstacleSpawnCounter = 0
        }

        let playerY = geo.size.height - playerBottomOffset

        updateScore(playerY: playerY)
        updateDifficulty()
        checkCollision(playerY: playerY)

        obstacles.removeAll { obstacle in
            obstacle.y - obstacle.size / 2 > geo.size.height
        }
    }

    func spawnObstacle(in geo: GeometryProxy) {
        let size = CGFloat.random(in: 44...72)
        let minX = size / 2
        let maxX = geo.size.width - size / 2
        let randomX = CGFloat.random(in: minX...maxX)

        let newObstacle = Obstacle(
            x: randomX,
            y: -size,
            size: size,
            usesPinkPalette: Bool.random()
        )

        obstacles.append(newObstacle)
    }

    func updateScore(playerY: CGFloat) {
        let playerTop = playerY - playerHitboxHeight / 2

        for index in obstacles.indices {
            let obstacleBottom = obstacles[index].y + obstacles[index].size / 2

            if obstacleBottom > playerTop && obstacles[index].hasScored == false {
                obstacles[index].hasScored = true
                score += 1

                if score > highScore {
                    highScore = score
                }
            }
        }
    }

    func updateDifficulty() {
        currentFallSpeed = baseFallSpeed + CGFloat(score) * 0.18

        let reducedInterval = baseSpawnInterval - (score / 4)
        currentSpawnInterval = max(minimumSpawnInterval, reducedInterval)
    }

    func restartGame(in geo: GeometryProxy) {
        gameTimer?.invalidate()
        softHaptic()

        score = 0
        obstacles = []
        obstacleSpawnCounter = 0
        isGameOver = false
        currentFallSpeed = baseFallSpeed
        currentSpawnInterval = baseSpawnInterval
        playerX = geo.size.width / 2
        screenShakeOffset = 0

        startGame(in: geo)
    }

    func checkCollision(playerY: CGFloat) {
        let playerHalfWidth = playerHitboxWidth / 2
        let playerHalfHeight = playerHitboxHeight / 2

        let playerLeft = playerX - playerHalfWidth
        let playerRight = playerX + playerHalfWidth
        let playerTop = playerY - playerHalfHeight
        let playerBottom = playerY + playerHalfHeight

        for obstacle in obstacles {
            let obstacleHalf = obstacle.size / 2

            let obstacleLeft = obstacle.x - obstacleHalf
            let obstacleRight = obstacle.x + obstacleHalf
            let obstacleTop = obstacle.y - obstacleHalf
            let obstacleBottom = obstacle.y + obstacleHalf

            let isOverlapping =
                playerRight > obstacleLeft &&
                playerLeft < obstacleRight &&
                playerBottom > obstacleTop &&
                playerTop < obstacleBottom

            if isOverlapping {
                isGameOver = true
                gameTimer?.invalidate()
                impactHaptic()
                triggerScreenShake()
                break
            }
        }
    }

    // MARK: - Effects

    func triggerScreenShake() {
        withAnimation(.easeInOut(duration: 0.06)) {
            screenShakeOffset = -10
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            withAnimation(.easeInOut(duration: 0.06)) {
                screenShakeOffset = 10
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.easeInOut(duration: 0.06)) {
                screenShakeOffset = -6
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.easeInOut(duration: 0.06)) {
                screenShakeOffset = 6
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
            withAnimation(.easeInOut(duration: 0.06)) {
                screenShakeOffset = 0
            }
        }
    }

    // MARK: - Feedback

    func impactHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    func softHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

#Preview {
    ContentView()
}
