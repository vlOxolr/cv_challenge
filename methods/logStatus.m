function logStatus(fig, msg)
    appData = guidata(fig);
    if isfield(appData, "statusLabel") && isvalid(appData.statusLabel)
        appData.statusLabel.Text = msg;
        drawnow;
    end
end