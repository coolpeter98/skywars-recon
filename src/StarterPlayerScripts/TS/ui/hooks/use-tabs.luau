-- useTabs

local useState: <T>(initialValue: T) -> (T, (T) -> ()) = require(
	game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib")
).import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "react").useState

type Tab = {
	Id: number,
	Hidden: (() -> boolean)?,
}

type Props = {
	Tabs: { Tab },
}

type UseTabsResult = {
	Tabs: { Tab },
	Selected: Tab?,
	SetTab: (id: number) -> (),
}

return {
	useTabs = function(props: Props): UseTabsResult
		local function getTab(id: number): Tab?
			local found: Tab? = nil
			for index, tab in props.Tabs do
				local _ = index - 1
				if tab.Id == id == true then
					return tab
				end
			end
			return found
		end

		local selected, setSelected = useState(getTab(0))
		local count = 0
		local visibleTabs = {}
		local state = {}
		for index, tab in props.Tabs do
			local _ = index - 1
			local hidden = tab.Hidden
			if hidden ~= nil then
				hidden = hidden()
			end
			if not hidden == true then
				count = count + 1
				visibleTabs[count] = tab
			end
		end
		state.Tabs = visibleTabs
		state.Selected = selected
		function state.SetTab(id)
			return setSelected(getTab(id))
		end
		return state
	end,
}
