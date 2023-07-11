import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const JobShipConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const { tracked_ids, threshold, department, difficulty } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="Menu">
          <LabeledList>
            <LabeledList.Item label="Tracked IDs">
              {tracked_ids}
            </LabeledList.Item>
            <LabeledList.Item label="Needed # of ID Swipes">
              {threshold}
            </LabeledList.Item>
            <LabeledList.Item label="Console Department">
              {department}
            </LabeledList.Item>
            <LabeledList.Item label="Current Difficulty">
              {difficulty}
            </LabeledList.Item>
            <LabeledList.Item label="Button">
              <Button
                content="Spawn a ship randomly."
                onClick={() => act('spawn_ship')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
