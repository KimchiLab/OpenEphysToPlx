function [a, t1] = TitleSuper(str, flag_below)

a = axes;
t1 = title(a, str);
a.Visible = 'off'; % set(a,'Visible','off');
t1.Visible = 'on'; % set(t1,'Visible','on');

if nargin > 1 && ~isempty(flag_below) && flag_below ~= 0
    t1.Position =  [0.5, -0.1];
end