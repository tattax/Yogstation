import { useBackend } from '../backend';
import { Button, LabeledList, Box, ProgressBar, Section, NoticeBox } from '../components';
import { Window } from '../layouts';

export const EvolutionMenu = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window width={900} height={480}>
      <Window.Content>
        <Section title="test">
          <LabeledList>
            <LabeledList.Item label="Mutation_Rate">
            <ProgressBar
                value={data.mutation_rate}
                minValue={0}
                maxValue={4}
                ranges={{
                  good: [0],
                  average: [2],
                  bad: [4],
                }}>
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Abilities">
          <LabeledList>
            {data.abilities.map(ability => (
              <LabeledList.Item label={ability.name} key={ability.name}>
                <Box>{ability.desc}</Box>
                <Box>Psi use cost: {ability.psi_cost}</Box>
                <Box>Cost to unlock: {ability.lucidity_cost}</Box>
                <Button
                  selected={ability.owned}
                  disabled={!ability.can_purchase}
                  onClick={() => act('unlock', {
                    'id': ability.id,
                  })}
                  content={ability.owned ? "Unlocked" : "Unlock"}
                />
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
        <Section title="Upgrades">
          <LabeledList>
            {data.mutations.map(mutation => (

              <LabeledList.Item label={mutation.name} key={mutation.name}>
                <Box>{mutation.desc}</Box>
                <Box>Cost to unlock: {mutation.mutation_cost}</Box>
                <Button
                  selected={mutation.owned}
                  disabled={!mutation.can_purchase}
                  onClick={() => act('upgrade', {
                    'id': mutation.id,
                  })}
                  content={mutation.owned ? "Unlocked" : "Unlock"}
                />
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};