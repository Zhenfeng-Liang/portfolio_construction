function paper1()

    
    numPaths = 2
    
    % Number of cores to run monte carlo. 
    MCNumCores = 2
    
    % If the assets are independent 
    independent = true;
    
    % The following 6 boolean flags determine if to run the test or
    % monte carlo for each model. Recommend to set only one flag
    % true per time
    
    % If to run the test for LN, MR or CIR model
    runLNTest = false
    runMRTest = false
    runCIRTest = false

    % If to run the Monte Carlo back test for each model 
    runLNMC = false
    runMRMC = false
    runCIRMC = true
    
    if runLNTest
        % Output directory, name it yourself, but please create a
        % folder with the name first in the current directory
        LNTestOutdir = 'LNTestOutput';
    	runLN(LNTestOutdir);
    end

    if runMRTest
        % Output directory, name it yourself, but please create a
        % folder with the name first in the current directory
        MRTestOutdir = 'MRTestOutput';
    	runMR(MRTestOutdir);
    end

    if runCIRTest
        % Output directory, name it yourself, but please create a
        % folder with the name first in the current directory
        CIRTestOutdir = 'CIRTestOutput';
    	runCIR(CIRTestOutdir);
    end

    % If false, run without consumption factor, otherwise run with
    % consumption 
    turnedOnConsumption = false
    
    % If run the approximation with consumption, only "CRRA"
    % utility type can be used. If not with consumption, it works
    % for "HARA" and "CARA" as well
    utilityType = 'HARA';
    
    if runLNMC   
        % Model parameters
    	modelParam3.modelType = 'LogNormal';
    	modelParam3.mu = [-0.5; 0.5; 0.1; -0.125; 0.2; 0.33; -0.083; 0.33; -0.583; -0.12];
    	modelParam3.vol = [0.1; 0.16; 0.3; 0.52; 0.14; 0.5; 1.0; 0.3; 0.5; 0.8];
    	xCurr3 = [0.8; 0.8; 2; 4; 1; 3; 6; 1.5; 2.4; 5.1];
    	modelParam3.vol = modelParam3.vol ./ xCurr3;
        
        % Output directory, name it yourself, but please create a
        % folder with the name first in the current directory 
        outdir = 'LNreb01';  
        
    	tic
        % by default, start from 1 path
    	runMonteCarlo(1, numPaths, modelParam3, xCurr3, outdir, ...
                      MCNumCores, independent, turnedOnConsumption, utilityType) 
    	display('Total time to run MC for LogNormal is below: ');
    	toc
    end

    if runMRMC
        % Model parameters
    	modelParam.modelType = 'MeanReverting';
    	modelParam.mu = [0.4; 1.3; 2.2; 3.5; 1.2; 4.0; 5.5; 2.0; 1.0; 4.5];
    	modelParam.vol = [0.1; 0.16; 0.3; 0.52; 0.14; 0.5; 1.0; 0.3; 0.5; 0.8];
    	modelParam.lambda = [2.10; 1.32; 1.10; 1.24; 1.56; 0.6; 1.9; 2.3; 1.05; 0.8];
    	xCurr = [0.8; 0.8; 2; 4; 1; 3; 6; 1.5; 2.4; 5.1];

        % Output directory, name it yourself, but please create a
        % folder with the name first in the current directory        
        outdir = 'MRLR2';
        
    	tic
        % by default, start from 1 path
    	runMonteCarlo(1, numPaths, modelParam, xCurr, outdir, ...
    	              MCNumCores, independent, turnedOnConsumption, ...
                      utilityType) 
    	display('Total time to run MC for MeanReverting is below: ');
    	toc
    end

    if runCIRMC
        % Model parameters
    	modelParam2.modelType = 'CIR';
    	modelParam2.mu = [0.4; 1.3; 2.2; 3.5; 1.2; 4.0; 5.5; 2.0; 1.0; 4.5];
    	modelParam2.vol = [0.1; 0.16; 0.3; 0.52; 0.14; 0.5; 1.0; 0.3; 0.5; 0.8];
    	modelParam2.vol = modelParam2.vol ./ sqrt(modelParam2.mu); 
    	modelParam2.lambda = [2.10; 1.32; 1.10; 1.24; 1.56; 0.6; 1.9; 2.3; 1.05; 0.8];
    	xCurr2 = [0.8; 0.8; 2; 4; 1; 3; 6; 1.5; 2.4; 5.1];

        % Output directory, name it yourself, but please create a
        % folder with the name first in the current directory
        outdir = 'CIRLR2';
        
    	tic
        % by default, start from 1 path        
    	runMonteCarlo(1, numPaths, modelParam2, xCurr2, outdir, ...
                      MCNumCores, independent, turnedOnConsumption, ...
                      utilityType) 
    	display('Total time to run MC for CIR is below: ');
    	toc
    end

end


function runLN(outdir)
% run lognormal test
    
    tic
    display('Start checking lognormal model');
        
    modelParam.modelType = 'LogNormal';
    modelParam.mu = [0.3];
    modelParam.vol = [0.33];
    
    pT = [0];
    
    corrMatr = eye(1);
    gamma = 10.0;
    xCurr = [1.0];
    tCurr = 0;
    T = 1.0;
    timeStep = 0.01;
    tol = 1e-6;

    w0 = 100000;
    numCores = 1;
    utilityType = 'HARA';
    
    turnedOnConsumption = false;
    
    display('Start checking lognormal leapfrog')

    
    model = Model(modelParam);
    portCalc = PortfolioCalculator(model, corrMatr);
    
    utiCalc = UtilityCalculator(gamma, utilityType);
    hamSys = HamiltonianSystem(portCalc, utiCalc);   
    
    wkbSolver = WKBHierarchySolver(hamSys, numCores);
    
    xT = wkbSolver.solveForTermX(xCurr, tCurr, T, timeStep, tol);
    
    [xFlow, pFlow] = wkbSolver.generateLfFlow(xT, pT, tCurr, T, timeStep, tol);
 
    
    t = tCurr:timeStep:T;    
    x_exact_1 = xT(1) * exp(-modelParam.mu(1) / gamma * (T - t));
 
    display('Plotting lognomal exact xFlow and leapfrog flow on the same graph. They should be on top of each other') 
    
    figure;
    
    subplot(1,2,1);
    plot(t, xFlow(1,:), 'Color', 'red', 'linewidth', 2);
    hold on;
    plot(t, x_exact_1, 'Color', 'blue', 'linewidth', 2);
    
    title('LN numerical xFlow and exact xFlow', ...
          'FontSize', 20);
    xlabel('time', 'FontSize', 20) % x-axis label
    ylabel('xFlow', 'FontSize', 20) % y-axis label    
    h = legend('Numerical','Exact');
    set(h, 'FontSize', 16);
    
    axes('Position',[.17 .6 .15 .15])
    box on
    
    diff = xFlow(1,:) - x_exact_1;
    plot(t, diff)
    
    title('Difference', 'FontSize', 20);
    xlabel('time', 'FontSize', 20) % x-axis label
    ylabel('difference','FontSize', 20) % y-axis label    

    
    %figure;
    subplot(1,2,2);
    plot(t, pFlow(1,:), 'Color', 'red', 'linewidth', 2);
    hold on;
    plot(t, t * 0, 'Color', 'blue', 'linewidth', 2);
    
    title(['LN numerical pFlow and exact ' ...
           'pFlow'], 'FontSize', 20)
    xlabel('time', 'FontSize', 20) % x-axis label
    ylabel('pFlow', 'FontSize', 20) % y-axis label
    h = legend('Numerical','Exact');
    set(h, 'FontSize', 16);

    str = sprintf('%s/LNFlow.png', outdir);
    set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 45 ...
                       20]);
    saveas(gcf, str);
    
    btST = 0;           
    btET = 1.0;               
    rebTS = 0.01;


    simulator = ModelEvolver();
    simData = simulator.EvolveEuler(xCurr, btST, btET, rebTS, corrMatr, ...
                                     model);

    F = size(simData, 1);
    m = size(simData, 2);

    maxRet = 0.02;
    maxDrawDown = -0.1;    
    maxLR = 2.0;
    constr = Constraint(maxRet, maxDrawDown, maxLR, false);
    
    bte = BtEngine(btST, btET, rebTS, constr);

    [wVec, phiMat, cVec] = bte.runBackTest(simData, wkbSolver, w0, ...
                                           turnedOnConsumption);

    exactStrategy = zeros(F, m-1);
    
    for i = 1:(m-1)        
        exactStrategy(:,i) = 1.0 / utiCalc.Au(wVec(1,i)) * portCalc.invInstCov(simData(:,i)) ...
            * model.driftV(simData(:,i));        
    end

    t = btST:rebTS:(btET-rebTS);    

    figure;
    
    plot(t, phiMat(1,:), 'Color', 'red', 'linewidth', 2);
    hold on;
    plot(t, exactStrategy(1,:), 'Color', 'blue', 'linewidth', 2);
    
    title('LN numerical and exact strategies', 'FontSize', 20);
    xlabel('rebalance time', 'FontSize', 20) % x-axis label
    ylabel('phi*', 'FontSize', 20) % y-axis label    
    h =legend('Numerical','Exact');
    set(h, 'FontSize', 16);
    
    axes('Position',[.17 .2 .2 .2])
    box on
    
    diff = phiMat(1,:) - exactStrategy;
    plot(t, diff, 'linewidth', 2);
    
    title('Difference', 'FontSize', 20);
    xlabel('rebalance time', 'FontSize', 20) % x-axis label
    ylabel('difference', 'FontSize', 20) % y-axis label    

    str = sprintf('%s/LNStrategy.png', outdir);
    set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 45 ...
                       20]);
    saveas(gcf, str);
    
    % Ploting strategy and stock price
    t = btST:rebTS:btET; 
    pos = [phiMat(1,:), 0];
    figure;
    [ax, h1, h2] = plotyy(t, simData(1,:), t, pos, 'plot', 'stairs');    
    set(h1, 'linewidth', 2, 'color', 'red');
    set(h2,  'linewidth', 2, 'color', 'blue');
    
    title('Simulated Stock Price and WKB approximate position', ...
          'FontSize', 20);
    xlabel('rebalance time', 'FontSize', 20) % x-axis label
    ylabel(ax(1), 'simulated stock price($)', 'color', 'red', 'FontSize', 20);
    ylabel(ax(2), 'position', 'color', 'blue', 'FontSize', 20);
    
    h = legend('simulated stock price','wkb strategy', 'Location', 'southeast');
    set(h, 'FontSize', 16);

    str = sprintf('%s/LNPnPos.png', outdir);
    set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 45 ...
                       20]);
    saveas(gcf, str);
    
    % Plotting PnL
    figure;
    plot(t, wVec(1,:), 'Color', 'red', 'linewidth', 2);    
    title('Cumulative PnL, LN', 'FontSize', 20);
    xlabel('rebalance time', 'FontSize', 20) % x-axis label
    ylabel('PnL', 'FontSize', 20) % y-axis label    

    str = sprintf('%s/LNPnL.png', outdir);
    set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 45 ...
                       20]);
    saveas(gcf, str);
    
    toc
end

function runMR(outdir)
% Run MR test
    
    tic
    
    display('Running MeanReverting');
    w0 = 100000;
    utilityType = 'HARA';
    turnedOnConsumption = false;
    numCores = 1;
    modelParam.modelType = 'MeanReverting';
    modelParam.mu = [0.4; 1.3; 2.2; 3.5; 1.2; 4.0; 5.5; 2.0; 1.0; 4.5];
    modelParam.vol = [0.1; 0.16; 0.3; 0.52; 0.14; 0.5; 1.0; 0.3; 0.5; 0.8];
    modelParam.lambda = [2.10; 1.32; 1.10; 1.24; 1.56; 0.6; 1.9; 2.3; 1.05; 0.8];

    F = length(modelParam.mu);

    % Generate correlation matrix
    tmp = randn(F, F);
    C = tmp * tmp';
    D = zeros(F, F);
    for i = 1:F
        C(i, i) = 2 * C(i, i);
        D(i,i) = sqrt(C(i,i));
    end
    corrMatr = inv(D) * C * inv(D)
    save('NewGeneratedMRcorr.mat', 'corrMatr');
    
    rankofCorr = rank(corrMatr)
    eigenV = eig(corrMatr)
    inverseCorr = inv(corrMatr)
    
    turnedOnConsumption = false;

    gamma = 10.0;
    xCurr = [0.8; 0.8; 2; 4; 1; 3; 6; 1.5; 2.4; 5.1];
    pT = zeros(length(xCurr),1);
        
    tCurr = 0;
    T = 1.0;
    timeStep = 0.01;
    tol = 1e-6;
    

    model = Model(modelParam);
    portCalc = PortfolioCalculator(model, corrMatr);    
    utiCalc = UtilityCalculator(gamma, utilityType);
    hamSys = HamiltonianSystem(portCalc, utiCalc);       
    wkbSolver = WKBHierarchySolver(hamSys, numCores);

    % Ploting Mean Reverting numerical flow
    xT = wkbSolver.solveForTermX(xCurr, tCurr, T, timeStep, tol);    
    [xFlow, pFlow] = wkbSolver.generateLfFlow(xT, pT, tCurr, T, timeStep, tol);
    
    % Ploting Mean Reverting exact flow
    t = tCurr:timeStep:T;    
    LAMBDA = diag(modelParam.lambda);
    cov = portCalc.instCov(xCurr);
    
    % changed due to the notation change, not the original ones
    A = [-hamSys.oneOverGamma * LAMBDA,  cov; ...
         -hamSys.kappa * hamSys.oneOverGamma * LAMBDA * inv(cov) * LAMBDA, hamSys.oneOverGamma ...
         * LAMBDA];
    
    m = [hamSys.oneOverGamma * LAMBDA * modelParam.mu; ...
         hamSys.kappa * hamSys.oneOverGamma * LAMBDA * inv(cov) * LAMBDA * modelParam.mu];
    
    [xFlowExact, pFlowExact] = calcExactMRFlow(t, A, T, xT, m);

    display('Plotting mean reverting exact xFlow and leapfrog flow on the same graph. They should be on top of each other') 
    
    F = length(xCurr);
    numAsset = 2;
    figure;        
    for i = 1:numAsset
        subplot(numAsset,2,2*i-1);
        plot(t, xFlow(i,:), 'Color', 'red', 'linewidth', 2);
        hold on;
        plot(t, xFlowExact(i,:), 'Color', 'blue', 'linewidth', 2);
        
        str1 = sprintf('Asset %d OU numerical xFlow and exact xFlow', i);
        title(str1, 'FontSize', 20);
        
        xlabel('time', 'FontSize', 20) % x-axis label
        ylabel('xFlow', 'FontSize', 20) % y-axis label    
        h = legend('Numerical','Exact');
        set(h, 'FontSize', 16);
        
        subplot(numAsset,2,2*i);
        plot(t, pFlow(i,:), 'Color', 'red', 'linewidth', 2);
        hold on;
        plot(t, pFlowExact(i,:), 'Color', 'blue', 'linewidth', 2);
        
        str2 = sprintf('Asset %d OU numerical pFlow and exact pFlow', i);
        title(str2, 'FontSize', 20);
        xlabel('time', 'FontSize', 20) % x-axis label
        ylabel('pFlow', 'FontSize', 20) % y-axis label        
        h = legend('Numerical', 'Exact');
        set(h, 'FontSize', 16);
    end
    
    str = sprintf('%s/MRFlow.png', outdir);
    set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 45 ...
                       20]);
    saveas(gcf, str);

    btST = 0;           
    btET = 1.0;               
    rebTS = 0.02;

    simulator = ModelEvolver();
    simData = simulator.EvolveEuler(xCurr, btST, btET, rebTS, corrMatr, ...
                                     model);

    maxRet = 0.2;
    maxDrawDown = -0.1;    
    maxLR = 2.0;
    constr = Constraint(maxRet, maxDrawDown, maxLR, true);

    bte = BtEngine(btST, btET, rebTS, constr);

    [wVec, phiMat, cVec] = bte.runBackTest(simData, wkbSolver, w0, ...
                                           turnedOnConsumption);

    t = btST:rebTS:btET;    
    
    % ploting strategy and simulated stock price
    figure;
    for i=1:numAsset
        subplot(numAsset,1, i)
        pos = [phiMat(i,:), 0];

        [ax, h1, h2] = plotyy(t, simData(i,:), t, pos, 'plot', 'stairs');    
        set(h1, 'linewidth', 2, 'color', 'red');
        set(h2,  'linewidth', 2, 'color', 'blue');
        
        str = sprintf(['Asset %d simulated stock price and wkb ' ...
                       'approximate position'],i);
        title(str,'FontSize', 20);
        
        xlabel('rebalance time', 'FontSize', 20) % x-axis label
        ylabel(ax(1), 'simulated stock price($)', 'color', 'red', 'FontSize', 20);
        ylabel(ax(2), 'position', 'color', 'blue', 'FontSize', 20);
        
        h = legend('simulated stock price','wkb strategy', 'Location', 'southeast');
        set(h, 'FontSize', 16);

    end

    str = sprintf('%s/MRPnPos.png', outdir);
    set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 45 ...
                       20]);
    saveas(gcf, str);
    
    % Ploting PnL
    figure;
    plot(t, wVec(1,:), 'Color', 'red', 'linewidth', 2);    
    title('Cumulative PnL, OU', 'FontSize', 20);
    xlabel('rebalance time', 'FontSize', 20); 
    ylabel('PnL', 'FontSize', 20);  

    str = sprintf('%s/MRPnL.png', outdir);
    set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 45 ...
                       20]);
    saveas(gcf, str);
    
    toc

end


function runCIR(outdir)
% Run CIR test
    
    tic
    
    display('Running CIR');
    w0 = 100000;
    utilityType = 'HARA';
    turnedOnConsumption = false;
    numCores = 1;
    modelParam.modelType = 'CIR';
    modelParam.mu = [0.4; 1.3; 2.2; 3.5; 1.2; 4.0; 5.5; 2.0; 1.0; 4.5];
    modelParam.vol = [0.1; 0.16; 0.3; 0.52; 0.14; 0.5; 1.0; 0.3; 0.5; 0.8];
    modelParam.vol = modelParam.vol ./ sqrt(modelParam.mu); 
    modelParam.lambda = [2.10; 1.32; 1.10; 1.24; 1.56; 0.6; 1.9; 2.3; 1.05; 0.8];
    xCurr = [0.8; 0.8; 2; 4; 1; 3; 6; 1.5; 2.4; 5.1];
    
    F = length(modelParam.mu);

    tmp = randn(F, F);
    C = tmp * tmp';
    D = zeros(F, F);
    for i = 1:F
        C(i, i) = 2 * C(i, i);
        D(i,i) = sqrt(C(i,i));
    end
    
    corrMatr = inv(D) * C * inv(D)
    save('NewGeneratedCIRcorr.mat', 'corrMatr');    
    rankofCorr = rank(corrMatr)
    eigenV = eig(corrMatr)
    inverseCorr = inv(corrMatr)
    
    turnedOnConsumption = false;

    gamma = 10.0;
    pT = zeros(length(xCurr),1);
        
    tCurr = 0;
    T = 1.0;
    timeStep = 0.01;
    tol = 1e-6;
    

    model = Model(modelParam);
    portCalc = PortfolioCalculator(model, corrMatr);    
    utiCalc = UtilityCalculator(gamma, utilityType);
    hamSys = HamiltonianSystem(portCalc, utiCalc);       
    wkbSolver = WKBHierarchySolver(hamSys, numCores);

    % Ploting CIR numerical flow
    xT = wkbSolver.solveForTermX(xCurr, tCurr, T, timeStep, tol);    
    [xFlow, pFlow] = wkbSolver.generateLfFlow(xT, pT, tCurr, T, timeStep, tol);
    
    display('Plotting CIR leapfrog flow on the same graph.'); 
    
    F = length(xCurr);
    numAsset = 2;
    t = tCurr:timeStep:T; 
    figure;        
    for i = 1:numAsset
        subplot(numAsset,2,2*i-1);
        plot(t, xFlow(i,:), 'Color', 'red', 'linewidth', 2);
        
        str1 = sprintf('Asset %d CIR numerical xFlow', i);
        title(str1, 'FontSize', 20);
        
        xlabel('time', 'FontSize', 20) % x-axis label
        ylabel('xFlow', 'FontSize', 20) % y-axis label    
        
        subplot(numAsset,2,2*i);
        plot(t, pFlow(i,:), 'Color', 'red', 'linewidth', 2);
        
        str2 = sprintf('Asset %d CIR numericla pFlow', i);
        title(str2, 'FontSize', 20);
        xlabel('time', 'FontSize', 20) % x-axis label
        ylabel('pFlow', 'FontSize', 20) % y-axis label        
    end
    
    str = sprintf('%s/CIRFlow.png', outdir);
    set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 45 ...
                       20]);
    saveas(gcf, str);

    btST = 0;           
    btET = 1.0;               
    rebTS = 0.02;

    simulator = ModelEvolver();
    simData = simulator.EvolveEuler(xCurr, btST, btET, rebTS, corrMatr, ...
                                     model);

    maxRet = 0.2;
    maxDrawDown = -0.1;    
    maxLR = 2.0;
    constr = Constraint(maxRet, maxDrawDown, maxLR, true);
    
    bte = BtEngine(btST, btET, rebTS, constr);
    simData
    [wVec, phiMat, cVec] = bte.runBackTest(simData, wkbSolver, w0, ...
                                           turnedOnConsumption);

    t = btST:rebTS:btET;    
    
    % ploting strategy and simulated stock price
    figure;
    for i=1:numAsset
        subplot(numAsset,1, i)
        pos = [phiMat(i,:), 0];

        [ax, h1, h2] = plotyy(t, simData(i,:), t, pos, 'plot', 'stairs');    
        set(h1, 'linewidth', 2, 'color', 'red');
        set(h2,  'linewidth', 2, 'color', 'blue');
        
        str = sprintf(['Asset %d simulated stock price and wkb ' ...
                       'approximate position'],i);
        title(str,'FontSize', 20);
        
        xlabel('rebalance time', 'FontSize', 20) % x-axis label
        ylabel(ax(1), 'simulated stock price($)', 'color', 'red', 'FontSize', 20);
        ylabel(ax(2), 'position', 'color', 'blue', 'FontSize', 20);
        
        h = legend('simulated stock price','wkb strategy', 'Location', 'southeast');
        set(h, 'FontSize', 16);

    end

    str = sprintf('%s/CIRPnPos.png', outdir);
    set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 45 ...
                       20]);
    saveas(gcf, str);
    
    % Ploting PnL
    figure;
    plot(t, wVec(1,:), 'Color', 'red', 'linewidth', 2);    
    title('Cumulative PnL, CIR', 'FontSize', 20);
    xlabel('rebalance time', 'FontSize', 20); 
    ylabel('PnL', 'FontSize', 20);  

    str = sprintf('%s/CIRPnL.png', outdir);
    set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 45 ...
                       20]);    
    saveas(gcf, str);
    
    toc

end


function [xFlow, pFlow] = calcExactMRFlow(sVec, A, T, y, m)
% Function to calculate the exact flow of Mean Reverting to compare
% with the approximation result
    
    numPoint = length(sVec);
        
    n = length(y);
    zerosVec = zeros(n, 1);
    termVal = [y; zerosVec];
    
    res = zeros(2*n, numPoint);
    
    for i = 1:numPoint
        
        s = sVec(i);
        term1 = expm(-(T - s) * A);
        term2 = (termVal + inv(A) * m);
        term3 = inv(A) * m;
        res(:,i) = term1 * term2 - term3;
        
    end
    
    xFlow = res(1:n, :);
    pFlow = res((n+1):2*n, :);
    
end


function runMonteCarlo(fromPaths, endPaths, modelParam, xCurr, outdir, ...
                       MCNumCores, independent, turnedOnConsumption, ...
                       utilityType)
    % Function to run Monte Carlo test.
    % Input:
    %      1. fromPaths: Starting number of paths. For naming
    %      convention in parallel computing. Normally, by default 1.
    %      
    %      2. endPaths: last number of paths. 
    %                   endPaths - fromPaths + 1 = numPaths 
    %
    %      3. modelParam: model parameters
    %
    %      4. xCurr: current asset price vector
    %
    %      5. outdir: output directory, please create a folder
    %      first
    %      
    %      6. MCNumCores: number of nodes in parallel computing
    %
    %      7. independent: If assets in the portfolio are
    %      independent, this is true, vice versa
    %
    %      8. turnedOnConsumption: true: run with consumption,
    %      false: run without consumption
    %
    %      9. utilityType: utility function's type
    
    str = sprintf('Monte Carlo back test, %s', modelParam.modelType);
    display(str);
    
    % Initial wealth
    w0 = 100000;
    
    % Its another parallel computing for test purpose, in Monte
    % Carlo, it needs to be 1.
    numCores = 1;
    
    % Risk aversion coefficient
    gamma = 10;
    
    % Back test starting time and ending time
    btST = 0;           
    btET = 1.0;               
    
    % rebalance time step, make sure (btET - btST) is the multiple
    % of rebTS
    rebTS = 0.1;

    % Maximum return constraint, once the return exceeds this
    % number, get out of position
    maxRet = 0.2;
    
    % Maximum draw down
    maxDrawDown = -0.1;
    
    % Maximum Leverage Ratio
    maxLR = 2.0;

    % number of asset to plot the simulated stock price and pos
    numAsset = 2;

    % Load the default correlation matrix in the paper
    corrMatrFile = strcat(modelParam.modelType, 'corr.mat');
    load(corrMatrFile);
    
    corrMatr = corrMatr;  % Do this declaration so that the body
                          % text in the parloop can see the corrMatr
    
    if independent
        corrMatr = diag(ones(1, length(xCurr))) % For independent correlated matrix, you may delete this later
    end
        
    % Set up approximation solver
    model = Model(modelParam);
    portCalc = PortfolioCalculator(model, corrMatr);    
    utiCalc = UtilityCalculator(gamma, utilityType);
    hamSys = HamiltonianSystem(portCalc, utiCalc);       
    wkbSolver = WKBHierarchySolver(hamSys, numCores);

    % Result containers
    wTVec = zeros(1, endPaths - fromPaths + 1);
    UTVec = zeros(1, endPaths - fromPaths + 1);
    JTVec = zeros(1, endPaths - fromPaths + 1);
    WIndCVec = zeros(1, endPaths - fromPaths + 1);
    
    corrMatr
    
    % Parallel computing for each path
    matlabpool('open', MCNumCores);
    parfor path = fromPaths:endPaths
        
        tic
        
        str = sprintf('Running model %s path %d', modelParam.modelType, ...
                      path);
        display(str);
        
        simulator = ModelEvolver();
        simData = simulator.EvolveEuler(xCurr, btST, btET, rebTS, corrMatr, ...
                                        model);

        % set up constraints
        constr = Constraint(maxRet, maxDrawDown, maxLR, false);
        
        % Initialize back test engine
        bte = BtEngine(btST, btET, rebTS, constr);
        
        % Run back test for one path
        [wVec, phiMat, cVec] = bte.runBackTest(simData, wkbSolver, w0, ...
                                               turnedOnConsumption);

        % The right flexible code should be the commented ones, but
        % parloop cant take this formula as index. So the
        % uncommented one is assuming fromPaths = 1
        % wTVec(path - fromPaths + 1) = wVec(end);
        % UTVec(path - fromPaths + 1) = utiCalc.U( wVec(end) );
        wTVec(path) = wVec(end);
        UTVec(path) = utiCalc.U( wVec(end) );
        
        % Additional results if considered consumption
        if turnedOnConsumption
            n = length(cVec);
            CUVec = zeros(1, n);
            
            for i=1:n
                CUVec(i) = utiCalc.U( cVec(i) );
            end
            
            JTVec(path) = sum(CUVec) * rebTS + UTVec(path);
            WIndCVec(path) = sum(cVec) * rebTS + wVec(end);
        end
        
        % Start to plot the back-test result
        t = btST:rebTS:btET;    
        
        % ploting strategy and simulated stock price
        figure;
        for i=1:numAsset
            subplot(numAsset,1, i)
            pos = [phiMat(i,:), 0];
            
            [ax, h1, h2] = plotyy(t, simData(i,:), t, pos, 'plot', 'stairs');    
            set(h1, 'linewidth', 2, 'color', 'red');
            set(h2,  'linewidth', 2, 'color', 'blue');
            
            str = sprintf(['Asset %d simulated stock price and wkb ' ...
                           'approximate position'],i);
            title(str,'FontSize', 20);
            
            xlabel('rebalance time', 'FontSize', 20) % x-axis label
            ylabel(ax(1), 'simulated stock price($)', 'color', 'red', 'FontSize', 20);
            ylabel(ax(2), 'position', 'color', 'blue', 'FontSize', 20);
            
            h = legend('simulated stock price','wkb strategy', 'Location', 'southeast');
            set(h, 'FontSize', 16);

        end

        str = sprintf('%s/%sPnPosPath%d.png', outdir, modelParam.modelType, ...
                      path);
        
        set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 45 ...
                            20]);
        saveas(gcf, str);

        % Additional figures if considered consumption
        if turnedOnConsumption
            
            figure
            cTmp = [cVec, 0];

            stairs(t, cTmp, 'linewidth', 2);
            
            str = sprintf(['Consumption rate %s'], modelParam.modelType);
            title(str,'FontSize', 20);
            
            xlabel('rebalance time', 'FontSize', 20);
            ylabel('Consumption rate ($/T)', 'color', 'red', 'FontSize', 20);
            
            str = sprintf('%s/%sCRPath%d.png', outdir, modelParam.modelType, path);
            set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 45 ...
                            20]);    
            saveas(gcf, str);            
        end
        
        % Ploting PnL
        figure;
        plot(t, wVec(1,:), 'Color', 'red', 'linewidth', 2);
        
        str = sprintf('Cumulative PnL %s', modelParam.modelType);
        title(str, 'FontSize', 20);
        xlabel('rebalance time', 'FontSize', 20); 
        ylabel('PnL', 'FontSize', 20);  

        str = sprintf('%s/%sPnLPath%d.png', outdir, modelParam.modelType, path);
        set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 45 ...
                            20]);    
        saveas(gcf, str);
        
        toc
    
    end
    matlabpool close;
    
    averageWT = mean(wTVec)
    averageUT = mean(UTVec)
    
    % Plot histogram of terminal wealth
    hist(wTVec)    
    str = sprintf('MC WT distribution %s', modelParam.modelType);
    title(str, 'FontSize', 20);
    xlabel('WT($)', 'FontSize', 20); 
    ylabel('Frequency', 'FontSize', 20);  

    str = sprintf('%s/%sWTHist%dTo%d.png', outdir, modelParam.modelType, ...
                  fromPaths, endPaths);
    set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 45 20]);    
    saveas(gcf, str);
    
    % Histogram of terminal utility
    hist(UTVec)
    str = sprintf('MC UT distribution %s', modelParam.modelType);
    title(str, 'FontSize', 20);
    xlabel('UT($)', 'FontSize', 20); 
    ylabel('Frequency', 'FontSize', 20);  

    str = sprintf('%s/%sUTHist%dTo%d.png', outdir, modelParam.modelType, ...
                  fromPaths, endPaths);
    set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 45 20]);    
    saveas(gcf, str);
    
    str = sprintf('%s/%sWTVec%dTo%d.mat', outdir, modelParam.modelType, ...
                  fromPaths, endPaths);
    save(str, 'wTVec');

    str = sprintf('%s/%sUTVec%dTo%d.mat', outdir, modelParam.modelType, ...
                  fromPaths, endPaths);    
    save(str, 'UTVec');

    % Additional histrograms if consiered consumption
    if turnedOnConsumption
        averageJT = mean(JTVec)
        averageWIndCVec = mean(WIndCVec)
        
        hist(JTVec)
        str = sprintf('Value function (J) distribution %s', modelParam.modelType);
        title(str, 'FontSize', 20);
        xlabel('J', 'FontSize', 20); 
        ylabel('Frequency', 'FontSize', 20);  

        str = sprintf('%s/%sJTHist%dTo%d.png', outdir, modelParam.modelType, ...
                      fromPaths, endPaths);
        set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 45 20]);    
        saveas(gcf, str);

        str = sprintf('%s/%sJTVec%dTo%d.mat', outdir, modelParam.modelType, ...
                      fromPaths, endPaths);
        save(str, 'JTVec');
        
        hist(WIndCVec)
        str = sprintf('Total wealth distribution %s', modelParam.modelType);
        title(str, 'FontSize', 20);
        xlabel('Wealth including consumption', 'FontSize', 20); 
        ylabel('Frequency', 'FontSize', 20);  

        str = sprintf('%s/%sTotWealthHist%dTo%d.png', outdir, modelParam.modelType, ...
                      fromPaths, endPaths);
        set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 45 20]);    
        saveas(gcf, str);

        str = sprintf('%s/%sWIndCVec%dTo%d.mat', outdir, modelParam.modelType, ...
                      fromPaths, endPaths);
        save(str, 'WIndCVec');
        
    end
    
end
